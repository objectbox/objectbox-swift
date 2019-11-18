//
// Copyright © 2019 ObjectBox Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// The Store represents an ObjectBox database on the local disk.
/// For each persisted object type, you can obtain a `Box` instance with the `box(for:)` method.
/// Boxes provide the interfaces for object persistence.
///
/// A typical setup sequence looks like this:
///
///     let store = try Store(directoryPath: pathToStoreData)
///     let personBox = store.box(for: Person.self)
///     let persons = try personBox.all()
///
/// - Note: You must run the code generator by building at least once to create a Store initializer according to
/// your data model. This generated initializer does not have a "model" parameter (that one is an internal initializer),
/// and comes with convenient defaults for its named parameters.
///

public class Store: CustomDebugStringConvertible {
    internal var cStore: OpaquePointer?
    internal var boxes = [UInt32: Any]() // entitySchemaId -> Box<N> instances.
    internal var boxesLock = DispatchSemaphore(value: 1)
    internal var attachedObjectsLock = DispatchSemaphore(value: 1)
    internal var attachedObjects = [String: AnyObject]()

    /// Returns the version number of ObjectBox C API the framework was built against.
    public static var version: String {
        return String(utf8String: obx_version_string()) ?? ""
    }

    /// The path to the directory containing our database files as it was passed to this instance when creating it.
    internal(set) public var directoryPath: String
    
    /// - important: this initializer is only used internally.
    /// Instead of this, use the generated initializer without the model parameter
    /// (trigger code generation if you don't see it yet).
    /// - Parameter model: A model description generated using a `ModelBuilder`
    /// - Parameter directory: The path to the directory in which ObjectBox should store database files.
    /// - Parameter maxDbSizeInKByte: Maximum size the database may take up on disk (default: 1 GB).
    /// - Parameter fileMode: The unix permissions (like 0o755) to use for creating the database files.
    /// - Parameter maxReaders: "readers" are a finite resource for which you need to define a maximum upfront. The
    ///                         default value is enough for most apps and usually you can ignore it completely. However,
    ///                         if you get the "maxReadersExceeded" error, you should verify your threading. For each
    ///                         thread, ObjectBox uses multiple readers. Their number (per thread) depends on number of
    ///                         types, relations, and usage patterns. Thus, if you are working with many threads (e.g.
    ///                         server-like scenario), it can make sense to increase the maximum number of readers. The
    ///                         default value 0 (zero) lets ObjectBox choose an internal default (currently around 120).
    ///                         So if you hit this limit, try values around 200-500.
    public init(model: OpaquePointer, directory: String = "objectbox", maxDbSizeInKByte: UInt64 = 1024 * 1024,
                fileMode: UInt32 = 0o755, maxReaders: UInt32 = 0) throws {
        directoryPath = directory
        cStore = try directory.withCString { ptr -> OpaquePointer? in
            var opts = obx_opt()
            try checkLastError()
            defer { if let opts = opts { obx_opt_free(opts) } }
            obx_opt_model(opts, model)
            try checkLastError()
            obx_opt_directory(opts, ptr)
            try checkLastError()
            obx_opt_max_db_size_in_kb(opts, Int(maxDbSizeInKByte))
            obx_opt_file_mode(opts, Int32(fileMode))
            obx_opt_max_readers(opts, Int32(maxReaders))
            let result = obx_store_open(opts)
            opts = nil // store owns it now, make sure defer doesn't free it.
            try checkLastError()
            return result
        }
    }
    
    deinit {
        close()
    }
    
    internal func close() {
        if let cStore = cStore {
            self.cStore = nil
            let err = obx_store_close(cStore)
            if err != OBX_SUCCESS {
                print("Error closing ObjectBox.Store: \(err)")
            }
        }
    }
    
    /// Return a box for reading/writing entities of the given class from/to the database.
    /// Obtain a a `Box` for the given type.
    ///
    /// - Parameter entityType: Object type to get a box for.
    /// - Returns: Box for the given type.
    public func box<T>(for entityType: T.Type = T.self) -> Box<T> where T: EntityInspectable & __EntityRelatable {
        guard T.entityInfo.entitySchemaId != 0 else {
            fatalError("entitySchemaId shouldn't be 0") // Swift doesn't know raise() never returns.
        }
        
        boxesLock.wait()
        defer { boxesLock.signal() }
        
        if let box = boxes[T.entityInfo.entitySchemaId] as? Box<T> {
            return box
        }
        
        let box: Box<T> = Box(store: self)
        boxes[T.entityInfo.entitySchemaId] = box
        
        return box
    }
    
    /// Delete the database files on disk. This Store object will not be usable after calling this.
    public func closeAndDeleteAllFiles() throws {
        self.close()
        obx_remove_db_files(directoryPath)
        try FileManager.default.removeItem(at: URL(fileURLWithPath: directoryPath))
    }

    internal let setUpMutexIdentifier: Bool = {
        #if os(OSX)
        /*
         macOS sandboxing insists on a naming scheme based on the application group identifier.
         This method looks up the first suitable application group identifier in the app's code signature
         and tells LMDB about it:
         */
        
        var myCodeObject: SecCode? // Swift takes care of releasing myCodeObject
        let err1 = SecCodeCopySelf([], &myCodeObject)
        if err1 == noErr, let myCodeObject = myCodeObject {
            var entitlementsInfo: CFDictionary?
            
            var staticCode: SecStaticCode?
            let err2 = SecCodeCopyStaticCode(myCodeObject, [], &staticCode)
            guard err2 == noErr else { print("Error finding static code: \(err2)"); return true }
            let err3 = SecCodeCopySigningInformation(staticCode!, SecCSFlags(rawValue: kSecCSSigningInformation),
                                                     &entitlementsInfo)
            if err3 == noErr, let signingInfo = entitlementsInfo as? [NSString: NSObject],
                let entitlements = signingInfo[kSecCodeInfoEntitlementsDict] as? [NSString: NSObject],
                let applicationGroups = entitlements["com.apple.security.application-groups"] as? [NSString] {
                
                if let appGroupIdentifier = applicationGroups.first(where: { $0.length <= 20 }) {
                    obx_posix_sem_prefix_set(appGroupIdentifier.appending("/"))
                    //print("found appGroupIdentifier \(appGroupIdentifier)")
                } else {
                    print("Could not find an application group identifier of 20 characters or fewer.")
                }
            } else if err3 != noErr { // noErr means app has no entitlements, likely not sandboxed.
                print("Error reading entitlements: \(err3)")
            }
            
        } else {
            print("Error finding entitlements: \(err1)")
        }
        #endif
        
        return true
    }()
    
    /// :nodoc:
    public func lazyAttachedObject<T: AnyObject>(key: String, creationBlock: () -> T) -> T {
        attachedObjectsLock.wait()
        defer { attachedObjectsLock.signal() }
        if let object = attachedObjects[key] as? T {
            return object
        }
        let object = creationBlock()
        attachedObjects[key] = object
        return object
    }

    /// :nodoc:
    public var debugDescription: String {
        return "<ObjectBox.Store \"\(directoryPath)\">"
    }
}

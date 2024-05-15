//
// Copyright © 2019-2023 ObjectBox Ltd. All rights reserved.
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
    internal var supportsLargeArrays = false

    /// The path to the directory containing our database files as it was passed to this instance when creating it.
    internal(set) public var directoryPath: String

    /// Returns the version of ObjectBox Swift.
    public static var version = "2.0.0"

    /// Pass this together with a String identifier as the directory path to use
    /// a file-less in-memory database.
    public static let inMemoryPrefix = "memory:"

    /// Returns the versions of ObjectBox Swift, the ObjectBox lib, and ObjectBox core.
    public static var versionAll: String {
        return version + " (lib: " + versionLib + ", core: " + versionCore + ")"
    }

    /// Returns the product name ("ObjectBox Swift") along with all versions (see versionAll()).
    public static var versionFullInfo: String {
        return "ObjectBox Swift " + versionAll
    }

    /// Returns the version of ObjectBox lib (C API).
    public static var versionLib: String {
        return String(utf8String: obx_version_string()) ?? ""
    }

    /// Returns the version of ObjectBox core ("internal" version).
    public static var versionCore: String {
        return String(utf8String: obx_version_core_string()) ?? ""
    }

    /// Attaches to a previously opened Store given its directory.
    public static func attachTo(directory: String) throws -> Store {
        let cStore: OpaquePointer? = obx_store_attach(directory)
        if cStore == nil {
            try checkLastError()  // Does not fire, but could change in the future
            throw ObjectBoxError.cannotAttachToStore(message: "Cannot attach to given directory")
        }
        return try Store(cStore: cStore!, directory: directory)
    }

    /// Returns if an open store (i.e. opened before and not yet closed) was found
    /// for the given `directory`.
    public static func isOpen(directory: String) throws -> Bool {
        return obx_store_is_open(directory)
    }

    /// Creates a store using the given model definition. In most cases, you would want
    /// to use the initializer without the model argument created by the code generator instead.
    /// 
    /// # In-memory database
    /// To use a file-less in-memory database, instead of a directory path pass `memory:` 
    /// together with an identifier string:
    /// ```swift
    /// let inMemoryStore = try Store(directoryPath: "memory:test-db")
    /// ```
    /// 
    /// - important: This initializer should only be used internally.
    ///   Instead, use the generated initializer without the model parameter
    ///   (trigger code generation if you don't see it yet).
    /// 
    /// - Parameters:
    ///   - model: A model description generated using a `ModelBuilder`.
    ///   - directoryPath: The directory path in which ObjectBox places its database files for this store,
    ///     or to use an in-memory database `memory:<identifier>`.
    ///   - maxDbSizeInKByte: Limit of on-disk space for the database files. Default is `1024 * 1024` (1 GiB).
    ///   - fileMode: UNIX-style bit mask used for the database files; default is `0o644`.
    ///     Note: directories become searchable if the "read" or "write" permission is set (e.g. 0640 becomes 0750).
    ///   - maxReaders: The maximum number of readers.
    ///     "Readers" are a finite resource for which we need to define a maximum number upfront.
    ///     The default value is enough for most apps and usually you can ignore it completely.
    ///     However, if you get the maxReadersExceeded error, you should verify your
    ///     threading. For each thread, ObjectBox uses multiple readers. Their number (per thread) depends
    ///     on number of types, relations, and usage patterns. Thus, if you are working with many threads
    ///     (e.g. in a server-like scenario), it can make sense to increase the maximum number of readers.
    ///     Note: The internal default is currently around 120. So when hitting this limit, try values around 200-500.
    ///   - readOnly: Opens the database in read-only mode, i.e. not allowing write transactions.
    public init(model: OpaquePointer, directory: String = "objectbox", maxDbSizeInKByte: UInt64 = 1024 * 1024,
                fileMode: UInt32 = 0o644, maxReaders: UInt32 = 0, readOnly: Bool = false) throws {
        directoryPath = directory
        supportsLargeArrays = obx_has_feature(OBXFeature_ResultArray)
        var opts = obx_opt()
        try checkLastError()
        if opts == nil { throw ObjectBoxError.illegalState(message: "Opts are nil but no error thrown") }
        defer { obx_opt_free(opts) }
        obx_opt_model(opts, model)
        try checkLastError()
        obx_opt_directory(opts, directory)
        obx_opt_max_db_size_in_kb(opts, maxDbSizeInKByte)
        obx_opt_file_mode(opts, UInt32(fileMode))
        obx_opt_max_readers(opts, UInt32(maxReaders))
        obx_opt_read_only(opts, readOnly)
        try checkLastError()  // Opt(ions) need just one check
        cStore = obx_store_open(opts)
        opts = nil // store owns it now, make sure defer doesn't free it.
        try checkLastError()
    }

    private init(cStore: OpaquePointer, directory: String) throws {
        directoryPath = directory
        supportsLargeArrays = obx_has_feature(OBXFeature_ResultArray)
        self.cStore = cStore
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

    internal func ensureCStore() throws -> OpaquePointer {
        guard let openCStore = cStore else { throw ObjectBoxError.illegalState(message: "Store is already closed") }
        return openCStore
    }

    /// Clone a previously opened store; while a store instance is usable from multiple threads, situations may exist
    /// in which cloning a store simplifies the overall lifecycle.
    /// E.g. when a store is used for multiple threads and it may only be fully released once the last thread completes.
    /// The returned store is a new instance with its own lifetime.
    public func clone() throws -> Store {
        let clonedStore = obx_store_clone(try ensureCStore())
        try checkLastError()
        return try Store(cStore: clonedStore!, directory: directoryPath)
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

        let libVersion = 1
        let genVersion = T.entityBinding.generatorBindingVersion()
        if libVersion != genVersion {
            let libOlderOrNewer = libVersion > genVersion ? "newer" : "older"
            fatalError("ObjectBox detected a version mismatch. The ObjectBox library version seems to be " +
                    "\(libOlderOrNewer) than the ObjectBox version that generated the binding code for " +
                    "type \"\(T.entityInfo.entityName)\" (version \(libVersion) vs. \(genVersion)).\n" +
                    "Please update ObjectBox to a consistent version and build again.\n" +
                    "For update instructions please visit https://swift.objectbox.io/install")
        }

        boxes[T.entityInfo.entitySchemaId] = box

        return box
    }

    /// Delete the database files on disk, including the database directory. This Store object will not be usable after calling this.
    ///
    /// For an in-memory database, this will just clean up the in-memory database.
    public func closeAndDeleteAllFiles() throws {
        self.close()
        obx_remove_db_files(directoryPath)
        if !directoryPath.hasPrefix(Store.inMemoryPrefix) {
            if FileManager.default.fileExists(atPath: directoryPath) {
                try FileManager.default.removeItem(atPath: directoryPath)
            }
        }        
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

                // Semaphore names in macOS are limited to 31 characters.
                // Internally, we need up to 11 chars to identify the semaphore,
                // thus the group ID must be equal or less than 20 (ASCII) charaters.
                if let appGroupIdentifier = applicationGroups.first(where: { $0.length <= 20 }) {
                    obx_posix_sem_prefix_set(appGroupIdentifier.appending("/"))
                    // print("found appGroupIdentifier \(appGroupIdentifier)")
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

    /// The SyncClient associated with this store. To create one, please check the Sync class and its makeClient().
    internal(set) public var syncClient: SyncClient?

    // MARK: Explicit Transactions

    /// Runs the given block inside a read/write transaction.
    ///
    /// You can e.g. wrap multiple `put` calls into a single write transaction to ensure a "all or nothing" semantic.
    /// Also, this is more efficient and provides better performance than having one transactions for each operation.
    ///
    /// You can nest read-only transaction into read/write transactions, but not vice versa.
    ///
    /// - Parameter block: Code that needs to run in a read/write transaction.
    /// - Returns: The forwarded result of `block`.
    /// - Throws: rethrows errors thrown inside, plus any ObjectBoxError that makes sense.
    public func runInTransaction<T>(_ block: () throws -> T) throws -> T {
        var result: T!

        try obx_runInTransaction(writable: true, { _ in
            result = try block()
        })

        return result
    }

    /// Internal version that gives the block a Transaction
    internal func obx_runInTransaction<T>(writable: Bool, _ block: (Transaction) throws -> T) throws -> T {
        let transaction = try Transaction(store: self, writable: writable)
        if writable {
            let result = try block(transaction)
            try transaction.commit()
            return result
        } else {
            let result = try block(transaction)
            try transaction.close()
            return result
        }
    }

    /// Internal version that gives the block a Transaction
    internal func obx_runInTransaction(writable: Bool, _ block: (Transaction) throws -> Void) throws {
        let transaction = try Transaction(store: self, writable: writable)
        try block(transaction)
        if writable {
            try transaction.commit()
        } else {
            try transaction.close()
        }
    }

    /// :nodoc::
    public func runInTransaction(_ block: () throws -> Void) throws {
        try obx_runInTransaction(writable: true, { _ in
            try block()
        })
    }

    /// Runs the given block inside a read(-only) transaction.
    ///
    /// You can e.g. wrap multiple `get` calls into a single read transaction to have a single consistent view on data.
    /// Also, this is more efficient and provides better performance than having one transactions for each operation.
    ///
    /// You can nest read-only transaction into read/write transactions, but not vice versa.
    ///
    /// - Parameter block: Code that needs to run in a read or read/write transaction.
    /// - Returns: The forwarded result of `block`.
    /// - Throws: rethrows errors thrown inside, plus any ObjectBoxError that makes sense.
    public func runInReadOnlyTransaction<T>(_ block: () throws -> T) throws -> T {
        return try obx_runInTransaction(writable: false, { _ in
            return try block()
        })
    }

    /// :nodoc:
    public func runInReadOnlyTransaction(_ block: () throws -> Void) throws {
        try obx_runInTransaction(writable: false, { _ in
            try block()
        })
    }
}

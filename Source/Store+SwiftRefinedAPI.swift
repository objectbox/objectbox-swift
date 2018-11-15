//
// Copyright © 2018 ObjectBox Ltd. All rights reserved.
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

// Documentation copies from OBXStore.h

/// On-disk store of the boxes for your object types.
///
/// In every app, you have to setup a `Store` only once and call `register(entity:)` for each
/// entity type to set the store up. Afterwards, you can obtain `Box` instances with
/// the `box(for:)` methods. Boxes provide the interfaces for object persistence.
///
/// The code generator will create a convenience initializer for you to use, with
/// sensible defaults set: `Store.init(directoryPath:)`.
///
/// A typical setup sequence looks like this:
///
///     let store = try Store(directoryPath: pathToStoreData)
///     store.register(entity: Person.self)
///     let personBox = store.box(for: Person.self)
///     let persons = personBox.all()
///
extension Store {

    /// A type that's marked as an `Entity` _and_ provides its own metadata.
    public typealias InspectableEntity = Entity & EntityInspectable & __EntityRelatable

    /// The Version of the ObjectBox library.
    public var version: String { return __version }

    /// The path of the database directory used by the store.
    public var directoryPath: String { return __directoryPath }

    /// Info that can be useful for debugging.
    public var diagnostics: String { return __diagnostics() }

    // MARK: Obtaining Object Boxes

    /// Register an entity type for use with the database.
    ///
    /// You have to call this for every entity type once after `Store` setup and before you try to use
    /// any variant of `box(for:)`.
    ///
    /// - Parameter entity: The type you want to register.
    public func register<T>(entity: T.Type) where T: InspectableEntity {
        self.register(entityInfo: T.entityInfo)
    }

    /// Obtain a a `Box` for the given type.
    ///
    /// - Note: You need to register types first in `register(entity:)` or else you will get a runtime exception.
    ///
    /// - Parameter entityType: Registered object type to get a box for.
    /// - Returns: Box for the given type.
    public func box<T>(for entityType: T.Type) -> Box<T> where T: InspectableEntity {
        return Box<T>(base: self.box(entityName: entityType.entityInfo.entityName))
    }

    /// Obtain a `Box` for the given relation's target type.
    ///
    /// - Note: You need to register types first in `register(entity:)` or else you will get a runtime exception.
    ///
    /// - Parameter relation: `ToOne` relation for a registered object type.
    /// - Returns: Box for the relation's target type.
    public func box<T>(for relation: ToOne<T>) -> Box<T> where T: InspectableEntity {
        let relationType = type(of: relation).Target.self
        return Box<T>(base: self.box(entityName: relationType.entityInfo.entityName))
    }
}

extension Store {

    // MARK: Transaction Management

    /// Runs the given block inside a transaction.
    ///
    /// Takes care of flattening nested transaction calls into a single transaction, and rolling back changes for you
    /// on error. You can e.g. wrap multiple `put` calls into a single write transaction to increase performance by
    /// re-using the resources of a single transaction to read and write data.
    ///
    /// You can nest read-only transaction into read/write transactions, but not vice versa.
    ///
    /// - Parameter block: Code that needs to run in a read/write transaction.
    /// - Returns: The forwarded result of `block`.
    /// - Throws: `NSError` with `OBXErrorDomain` when an action  inside the `block` throws.
    public func runInTransaction<T>(_ block: () throws -> T) throws -> T {
        var outError: NSError?
        var result: T!

        __runInTransaction({ errPtr in
            do {
                result = try block()
            } catch {
                errPtr?.pointee = error as NSError
            }
        }, error: &outError)

        if let error = outError {
            throw error
        }

        return result
    }

    /// Runs the given block inside a transaction.
    ///
    /// Takes care of flattening nested transaction calls into a single transaction, and rolling back changes for you
    /// on error. You can e.g. wrap multiple `put` calls into a single write transaction to increase performance by
    /// re-using the resources of a single transaction to read and write data.
    ///
    /// You can nest read-only transaction into read/write transactions, but not vice versa.
    ///
    /// - Parameter block: Code that needs to run in a read/write transaction.
    /// - Throws: `NSError` with `OBXErrorDomain` when an action  inside the `block` throws.
    public func runInTransaction(_ block: () throws -> Void) throws {
        var outError: NSError?

        __runInTransaction({ errPtr in
            do {
                try block()
            } catch {
                errPtr?.pointee = error as NSError
            }
        }, error: &outError)

        if let error = outError {
            throw error
        }
    }

    /// Runs the given block inside a transaction.
    ///
    /// Takes care of flattening nested transaction calls into a single transaction, and rolling back changes for you
    /// on error. You can e.g. wrap multiple `put` calls into a single write transaction to increase performance by
    /// re-using the resources of a single transaction to read and write data.
    ///
    /// You can nest read-only transaction into read/write transactions, but not vice versa.
    ///
    /// - Parameter block: Code that needs to run in a read/write transaction.
    /// - Returns: The forwarded result of `block`.
    public func runInTransaction<T>(_ block: () -> T) -> T {
        var result: T!

        __runInTransaction({ _ in
            result = block()
        }, error: nil)

        return result
    }

    /// Runs the given block inside a transaction.
    ///
    /// Takes care of flattening nested transaction calls into a single transaction, and rolling back changes for you
    /// on error. You can e.g. wrap multiple `put` calls into a single write transaction to increase performance by
    /// re-using the resources of a single transaction to read and write data.
    ///
    /// - Parameter block: Code that needs to run in a read/write transaction.
    public func runInTransaction(_ block: () -> Void) {
        __runInTransaction({ _ in block() }, error: nil)
    }

    /// Runs the given block inside a read(-only) transaction.
    ///
    /// Takes care of flattening nested transaction calls into a single transaction, and rolling back changes for you
    /// on error. You can e.g. wrap multiple `get` calls into a single read transaction to increase performance by
    /// re-using the resources for reading data into memory.
    ///
    /// You can nest read-only transaction into read/write transactions, but not vice versa.
    ///
    /// - Parameter block: Code that needs to run in a read or read/write transaction.
    /// - Throws: `NSError` with `OBXErrorDomain` when an action inside the `block` throws.
    public func runInReadOnlyTransaction(_ block: () throws -> Void) throws {
        var outError: NSError?

        __runInReadOnlyTransaction({ errPtr in
            do {
                try block()
            } catch {
                errPtr?.pointee = error as NSError
            }
        }, error: &outError)

        if let error = outError {
            throw error
        }
    }

    /// Runs the given block inside a read(-only) transaction.
    ///
    /// Takes care of flattening nested transaction calls into a single transaction, and rolling back changes for you
    /// on error. You can e.g. wrap multiple `get` calls into a single read transaction to increase performance by
    /// re-using the resources for reading data into memory.
    ///
    /// You can nest read-only transaction into read/write transactions, but not vice versa.
    ///
    /// - Parameter block: Code that needs to run in a read or read/write transaction.
    public func runInReadOnlyTransaction(_ block: () -> Void) {
        __runInReadOnlyTransaction({ _ in block() }, error: nil)
    }
}

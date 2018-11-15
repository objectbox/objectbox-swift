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

// Wrapper for OBXBox that provides a native Swift API. Unlike OBXStore, exposing OBXBox to Swift
// proved to be too limiting. Swift generics are just too useful.

/// A box to store objects of a particular type.
///
/// Thread-safe.
public class Box<E>
where E: Store.InspectableEntity {

    /// The object type this box is managing.
    public typealias EntityType = E

    internal let base: __OBXBox

    internal init(base: __OBXBox) {
        self.base = base
    }

    // MARK: Box Introspection

    /// The count of all stored objects in this box.
    ///
    /// See `count(limit:)` for a variant with an upper limit.
    public var count: Int {
        return Int(base.count())
    }

    /// Indicates whether there are any objects stored inside the box.
    public var isEmpty: Bool { return base.isEmpty }

    /// Limits counting all objects inside the box.
    ///
    /// See `count` for a variant without an upper limit that is equivalent to `count(limit: 0)`.
    ///
    /// - Parameter limit: Maximum value to count up to, or 0 for unlimited count.
    /// - Returns: The count of all stored objects in this box or the given `limit`, whichever is lower.
    public func count(limit: Int) -> Int {
        return Int(base.count(limit: UInt64(limit)))
    }

    // MARK: Persisting Objects

    /// Puts the given object in the box (aka persisting it).
    ///
    /// - Parameter entity: Object to persist.
    /// - Returns: ID of the object after persistence. If `entity` was persisted before, it's the same as its ID.
    ///   If `entity` is a new object, the ID is generated.
    /// - Throws: `NSError` with `OBXErrorDomain` for database write errors and transaction errors.
    @discardableResult
    public func put(_ entity: EntityType) throws -> Id<EntityType> {
        return try Id<EntityType>(base.put(entity))
    }

    /// Puts the given entities in a box using a single transaction.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Throws: `NSError` with `OBXErrorDomain` for database write errors and transaction errors.
    public func put(_ entities: [EntityType]) throws {
        try base.putAll(entities)
    }

    internal func put(_ relatedEntity: ToOne<EntityType>) throws -> Id<EntityType>? {
        guard let entity = relatedEntity.target else { return nil }
        return try Id<EntityType>(base.put(entity))
    }

    // MARK: Reading Objects

    /// Get the stored objects for the given ID.
    ///
    /// - Parameter entityId: ID of the object.
    /// - Returns: The entity, if an object with `entityId` was found, `nil` otherwise.
    public func get(_ entityId: Id<EntityType>) -> EntityType? {
        return base.get(entityId.value) as? EntityType
    }

    /// Gets entities from the box for each ID in `entityIds`.
    ///
    /// - Parameter entityIds: Object IDs to map to objects.
    /// - Returns: Dictionary of all `entityIds` and the corresponding objects.
    ///   Value of a key is `NSNull` when not found.
    public func dictionaryWithEntities(forIds entityIds: [Id<EntityType>]) -> [Id<EntityType> : Any] {
        let dictionary = base.dictionaryWithEntities(forIds: entityIds.map { NSNumber(value: $0.value) })
        var result: [Id<EntityType> : Any] = [:]
        for (key, value) in dictionary {
            result[Id<EntityType>(key.uint64Value)] = value
        }
        return result
    }

    /// Gets all objects from the box.
    ///
    /// - Returns: All stored Objects in this Box.
    public func all() -> [EntityType] {
        // swiftlint:disable force_cast
        return base.all() as! [EntityType]
        // swiftlint:enable force_cast
    }

    // MARK: Removing entities

    /// Removes (deletes) the Object by its ID.
    ///
    /// - Parameter entityId: ID of the object to delete.
    /// - Throws: `NSError` with `OBXErrorDomain` for database write errors.
    public func remove(_ entityId: Id<EntityType>) throws {
        try base.remove(entityId.value)
    }

    /// Removes (deletes) the given Object.
    ///
    /// - Parameter entity: Object to delete.
    /// - Throws: `NSError` with `OBXErrorDomain` for database write errors.
    public func remove(_ entity: EntityType) throws {
        try base.remove(entity)
    }

    /// Removes (deletes) the given objects in a single transaction.
    ///
    /// It is valid to pass objects here that haven't been persisted yet.
    ///
    /// - Parameter entities: Objects to delete.
    /// - Returns: Count of objects that were removed.
    /// - Throws: `NSError` with `OBXErrorDomain` for database write errors.
    @discardableResult
    public func remove(_ entities: [EntityType]) throws -> UInt64 {
        return try base.remove(entities)
    }

    /// Removes (deletes) **all** objects in a single transaction.
    ///
    /// - Returns: Count of items that were removed.
    /// - Throws: `NSError` with `OBXErrorDomain` for database write errors.
    @discardableResult
    open func removeAll() throws -> UInt64 {
        return try base.removeAll()
    }
}

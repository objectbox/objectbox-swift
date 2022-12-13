//
// Copyright © 2018-2020 ObjectBox Ltd. All rights reserved.
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

// swiftlint:disable force_try

// Of the form `ToMany<OtherEntity>`. Initialize with `nil` when you define properties.
// The codegen uses the `relation()` and `backlink()` static factory methods to create instances.
// TODO: codegen should rather update an existing ToMany and not replace the object?
//
// Code generator will figure out a call to the value-ful initializer.

/// Declaration of a to-many relationship to objects of a certain type.
///
/// Initialize with `nil` in your type declarations. The code generator will set different values.
///
/// Example:
///
///     class Customer: Entity {
///         var id: EntityId<Customer> = 0
///
///         /// Annotation with ReferencedType's property name is required; Order is "ReferencedType",
///         /// Customer is "OwningType"
///         // objectbox: backlink = "customer"
///         var orders: ToMany<Order> = nil
///         // ...
///     }
///
///     class Order: Entity {
///         var id: EntityId<Order> = 0
///         var customer: ToOne<Customer> = nil
///         // ...
///     }
///
/// ## Removing relations
///
/// A ToMany can be modified just like any other RangeReplaceableCollection. Once you have
/// changed your relation as needed, call `applyToDb()` on it to actually write the changes
/// to disk.
///
/// - Note: You can also use a ToMany to create backlinks from `ToOne` relations. Use the
///   `// objectbox: backlink = "propertyName"` annotation to tell the code generator which property of
///   `ToMany.ReferencedType` should be used to determine the backlinks.
public final class ToMany<S: EntityInspectable & __EntityRelatable>: ExpressibleByNilLiteral
where S == S.EntityBindingType.EntityType {

    /// The type referenced by this relation (where we point):
    public typealias ReferencedType = S

    enum RelationInfo: Equatable {
        case empty
        case toOneBacklink(propertyId: obx_schema_id, /*referencedId: Id,*/ owningId: Id)
        case toMany(relationId: obx_schema_id, referencedId: Id)
        case toManyBacklink(relationId: obx_schema_id, owningId: Id)
    }

    var collectionResolved: [ReferencedType]?

    /// Indicates if the target objects have been resolved from the database yet.
    public var resolved: Bool { collectionResolved != nil }

    var collection: [ReferencedType] {
        var col = collectionResolved
        while col == nil {
            try! resolveFromDb()
            col = collectionResolved
        }
        return col!
    }

    private let info: RelationInfo
    private var owningBox: OpaquePointer? /* OBX_box */ // nil if entity has never been persisted.
    private var referencedBox: Box<ReferencedType>?     // nil if entity has never been persisted.
    // Lock for resolverAndCollection, added, removed.
    private var relationCacheLock = DispatchSemaphore(value: 1)

    private var added = Set<IdComparableReferencedType>() // Must take out relationCacheLock to access.
    private var removed = Set<IdComparableReferencedType>() // Must take out relationCacheLock to access.

    public var hasPendingDbChanges: Bool {
        !added.isEmpty || !removed.isEmpty
    }

    /// Initialize an empty ToMany relation.
    ///
    /// Use this during object creation. The actual `ToMany` initialization with resolvable
    /// backlinks happens in `ToMany.relation(sourceBox:sourceId:targetBox:relationId:)`,
    /// `ToMany.backlink(sourceBox:sourceProperty:targetId:)` etc. which are
    /// called by the code generator.
    public init(nilLiteral: ()) {
        self.info = .empty
    }

    /// Used by the code generator to connect a backlink to the class containing the corresponding ToOne.
    /// `sourceProperty` is the property on ReferencedType that will be used to search for backlinks.
    public static func backlink<OwningType>(sourceBox: Box<ReferencedType>,
                                            sourceProperty: Property<ReferencedType, EntityId<OwningType>,
        OwningType>,
                                            targetId: EntityId<OwningType>) -> ToMany<ReferencedType> {
        return ToMany(sourceBox: sourceBox, sourceProperty: sourceProperty, targetId: targetId)
    }

    /// Used by the code generator to associate a to-many relation with its store and the model.
    /// `relationId` is the ID of the standalone to-many-relation connecting the entities.
    public static func relation<OwningType>(sourceId: EntityId<OwningType>,
                                            targetBox: Box<ReferencedType>,
                                            relationId: obx_schema_id) -> ToMany<ReferencedType> {
        return ToMany(sourceId: sourceId, targetBox: targetBox, relationId: relationId)
    }

    /// Used by the code generator to associate a to-many backlink with its store and the model.
    /// `relationId` is the ID of the standalone to-many-relation connecting the entities.
    public static func backlink<OwningType>(sourceBox: Box<ReferencedType>,
                                            targetId: EntityId<OwningType>,
                                            relationId: obx_schema_id) -> ToMany<ReferencedType>
        where OwningType == OwningType.EntityBindingType.EntityType {
        return ToMany(sourceBox: sourceBox, targetId: targetId, relationId: relationId)
    }

    internal init<OwningType>(sourceBox: Box<ReferencedType>,
                              sourceProperty: Property<ReferencedType, EntityId<OwningType>, OwningType>,
                              targetId: EntityId<OwningType>) {
        precondition(!targetId.needsIdGeneration, "Can form Backlinks for persisted entities only.")
        self.referencedBox = sourceBox
        self.info = .toOneBacklink(propertyId: sourceProperty.propertyId, owningId: targetId.value)
    }

    internal init<OwningType>(sourceId: EntityId<OwningType>,
                              targetBox: Box<ReferencedType>,
                              relationId: obx_schema_id) {
        self.owningBox = obx_box(targetBox.store.cStore, OwningType.entityInfo.entitySchemaId)
        self.referencedBox = targetBox
        self.info = .toMany(relationId: relationId, referencedId: sourceId.value)
    }

    internal init<OwningType>(sourceBox: Box<ReferencedType>,
                              targetId: EntityId<OwningType>,
                              relationId: obx_schema_id)
    where OwningType == OwningType.EntityBindingType.EntityType {
        referencedBox = sourceBox
        self.owningBox = obx_box(sourceBox.store.cStore, OwningType.entityInfo.entitySchemaId)
        self.info = .toManyBacklink(relationId: relationId, owningId: targetId.value)
    }

    /// Discard the cached objects and any pending changes in this relation.
    /// The next time you access this relation's entities, it will re-load the current state from the database.
    public func reset() {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        collectionResolved = nil
        added.removeAll()
        removed.removeAll()
    }

    /// - Important: Must lock relationCacheLock to call this.
    internal func applyToOneBacklinkToDb(_ box: Box<ReferencedType>, propertyId: obx_schema_id, owningId: Id) throws {
        guard owningId != 0 else {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(
                    message: "Owning entity of backlink hasn't been put yet.")
        }
        // Clear & set IDs before actually applying to DB for more defined behavior if a put throws (& less TX time)
        let targetBinding = ReferencedType.entityBinding
        for target in removed { targetBinding.setToOneRelation(propertyId, of: target.entity, to: nil) }
        for target in added { targetBinding.setToOneRelation(propertyId, of: target.entity, to: owningId) }

        try box.store.runInTransaction {
            try added.forEach { try box.put($0.entity) }
            try removed.forEach { try box.put($0.entity) }
        }
    }

    /// - Important: Must lock relationCacheLock to call this.
    internal func applyToManyStandaloneToDb(_ box: Box<ReferencedType>, relationId: obx_schema_id, ownerObjectId: Id)
    throws {
        guard let cBox = owningBox else {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message:
            "Cannot apply changes to the database (owning Box unavailable)")
        }
        guard ownerObjectId != 0 else {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Referenced object hasn't been put yet.")
        }

        // Note: decided against sorted IDs; relations are written two way ({SOURCE}{TARGET} and {TARGET}{SOURCE}).
        //       Thus the internal relation cursor has to seek back and forth anyway, probably voiding any perf gain.
        //       If we had bulk ops in the core for this, the core could sort...
        try box.store.runInTransaction {
            for target in removed {
                if target.entityId == 0 {
                    // Does this really occur? Only persisted objects should land in the removed set?
                    throw ObjectBoxError.cannotRelateToUnsavedEntities(
                            message: "Removed target object hasn't been put yet.")
                }
                let obxErr = obx_box_rel_remove(cBox, relationId, ownerObjectId, target.entityId)
                try check(error: obxErr, message: "Could not remove relation data")
            }
            for target in added {
                var targetId: Id = target.entityId
                if targetId == 0 {
                    targetId = try box.put(target.entity).value
                }
                let obxErr = obx_box_rel_put(cBox, relationId, ownerObjectId, targetId)
                try check(error: obxErr, message: "Could not add relation data")
            }
        }
    }

    /// - Important: Must lock relationCacheLock to call this.
    internal func applyToManyStandaloneBacklinkToDb(_ box: Box<ReferencedType>, relationId: obx_schema_id,
                                                    ownerObjectId: Id) throws {
        // Need to use the target box as it owns the relation.
        // Thus we need to "reverse" the direction, e.g. the owning object of the ToMany becomes the relation target.
        guard ownerObjectId != 0 else {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Owning entity of backlink hasn't "
                    + "been put yet.")
        }

        try box.store.runInTransaction {
            for target in removed {
                if target.entityId == 0 {
                    // Does this really occur? Only persisted objects should land in the removed set?
                    throw ObjectBoxError.cannotRelateToUnsavedEntities(
                            message: "Removed target object hasn't been put yet.")
                }
                try box.removeRelation(relationId: relationId, sourceId: target.entityId, targetId: ownerObjectId)
            }
            for target in added {
                var targetId: Id = target.entityId
                if targetId == 0 {
                    targetId = try box.put(target.entity).value
                }
                try box.putRelation(relationId: relationId, sourceId: target.entityId, targetId: ownerObjectId)
            }
        }
    }

    /// Apply changes made to this ToMany relation to the database (making changes persistent).
    /// If this collection contains new objects that were not persisted yet, applyToDb() will put them on-the-fly.
    /// For this to work the host object (the object owing this ToMany) must have been put before as its Id is required.
    /// Alternatively, if the host object is new itself, put the host object instead:
    /// ObjectBox will then call applyToDb() to all ToMany relations internally.
    ///
    /// When you modify a ToMany using Collection functions like append() or remove(), ToMany tracks these changes
    /// in memory but does not make them persistent just yet. This allows you to efficiently prepare the data.
    /// Then you can call this method to actually write to the database.
    ///
    /// Note: before version 1.4, manual puts for new objects were required.
    public func applyToDb() throws {
        // TODO check this locking; might it deadlock when e.g. another thread calls applyToDb() from inside a TX?
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }

        guard hasPendingDbChanges else { return }  // Short cut: nothing to do
        guard let box = referencedBox else {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Must put the entity before you can apply().")
        }

        switch info {
        case .empty: throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Relation info not available yet")
        case .toOneBacklink(let propertyId, let owningId):
            try applyToOneBacklinkToDb(box, propertyId: propertyId, owningId: owningId)
        case .toManyBacklink(let relationId, let owningId):
            try applyToManyStandaloneBacklinkToDb(box, relationId: relationId, ownerObjectId: owningId)
        case .toMany(let relationId, let referencedId):
            try applyToManyStandaloneToDb(box, relationId: relationId, ownerObjectId: referencedId)
        }

        added.removeAll()
        removed.removeAll()
    }

    /// Checks the state of this ToMany if calls like applyToDb(), resolveFromDb(), getUncachedFromDb() are
    /// likely to succeed.
    public var canInteractWithDb: Bool {
        referencedBox != nil && hostId() != 0
    }

    /// Id of the object hosting this ToMany
    func hostId() -> Id {
        switch info {
        case .empty: return 0
        case .toOneBacklink(_, let owningId): return owningId
        case .toManyBacklink(_, let owningId): return owningId
        case .toMany(_, let referencedId): return referencedId
        }
    }

    /// To ensure no error is forced when accessing elements of this ToMany, you can opt to resolve this ToMany upfront.
    /// This triggers loading the target objects with the possibility of a thrown error.
    public func resolveFromDb() throws {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        try ensureCollectionResolved()
    }

    /// Caller must have lock on relationCacheLock
    @discardableResult private func ensureCollectionResolved() throws -> [ReferencedType] {
        var collection = collectionResolved
        if collection == nil {
            if info == .empty {
                // Special case handling for generated code in postPut(): checks isEmpty for .empty before replacing.
                // TODO change generated code (check resolved first?) and throw here?
                collection = []
            } else if hostId() == 0 { // Not persisted to DB yet
                collection = []
            } else {
                collection = try getUncachedFromDb()
            }
            collectionResolved = collection
        }
        return collection!
    }

    /// Gets fresh target objects unrelated to any cached value in this ToMany. Also no cache is updated.
    public func getUncachedFromDb() throws -> [ReferencedType] {
        guard let box = referencedBox else {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Relation info not available yet")
        }
        return try box.store.runInReadOnlyTransaction {
            let ids = try getUncachedIdsFromDb()
            return try box.get(ids)
        }
    }

    /// Gets fresh target IDs unrelated to any cached value in this ToMany. Also no cache is updated.
    public func getUncachedIdsFromDb() throws -> [ReferencedType.EntityBindingType.IdType] {
        guard let box = referencedBox else {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Relation info not available yet")
        }
        switch info {
        case .empty: throw ObjectBoxError.illegalState(message: "Impossible state: box but empty")
        case .toOneBacklink(let propertyId, let owningId):
            return try box.backlinkIds(propertyId: propertyId, entityId: owningId)
        case .toMany(let relationId, let referencedId):
            return try box.relationTargetIds(relationId: relationId, sourceId: referencedId.value,
                    targetType: ReferencedType.self)
        case .toManyBacklink(let relationId, let owningId):
            return try box.relationSourceIds(relationId: relationId, targetId: owningId,
                    targetType: ReferencedType.self)
        }
    }

    /// Replace the entire contents of this relation with the contents of the given collection.
    public func replace<C>(_ newElements: __owned C)
        where C: Collection, ReferencedType == C.Element {
            replaceSubrange(self.startIndex ..< self.endIndex, with: newElements)
    }
}


// MARK: - RandomAccessCollection

extension ToMany: RandomAccessCollection {
    public typealias Index = Int

    /// The position of the first element in a nonempty collection.
    public var startIndex: Index {
        return collection.startIndex
    }

    /// The collections "past the end" position -- that is, the position one greater
    /// than the last valid subscript argument.
    public var endIndex: Index {
        return collection.endIndex
    }

    // swiftlint:disable identifier_name
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than `endIndex`.
    /// - Returns: The index immediately after `i`.
    public func index(after i: Index) -> Index {
        return collection.index(after: i)
    }

    /// Returns the position immediately before the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than `startIndex`.
    /// - Returns: The index immediately before `i`.
    public func index(before i: Index) -> Index {
        return collection.index(before: i)
    }
    // swiftlint:enable identifier_name
    /// Enable accessing elements of the relation as e.g. `customer[0]` via array subscript operator.
    public subscript(position: Index) -> ReferencedType {
        return collection[position]
    }
}

// Attention! The official docs at https://developer.apple.com/documentation/swift/rangereplaceablecollection state:
// "To add [...] conformance to your custom collection, add an empty initializer and the replaceSubrange(_:with:) method
// to your custom type. RangeReplaceableCollection provides default implementations of all its other methods using this
// initializer and method."
// However, beware of functions mutating `self` and thus clear out (!) ToMany, e.g. leaving it in a "detached" state
// without previously available `Box`es. Example: removeAll()
extension ToMany: RangeReplaceableCollection {
    public convenience init() {
        self.init(nilLiteral: ())
    }

    // To do: can we officially `override` without compiler complaining?
    public func replaceSubrange<C, R>(_ subrange: R, with newElements: __owned C)
        where C: Collection, R: RangeExpression, ReferencedType == C.Element, Index == R.Bound {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        let collection = try! ensureCollectionResolved()
        if collection.isEmpty && newElements.isEmpty { return }

        let slice: ArraySlice<S> = collection[subrange]
        var removeSet = Set<IdComparableReferencedType>(minimumCapacity: slice.count)
        for obj in slice {
            removeSet.insert(IdComparableReferencedType(entity: obj))
        }

        var addSet = Set<IdComparableReferencedType>(minimumCapacity: newElements.count)
        for obj in newElements {
            let wrapped = IdComparableReferencedType(entity: obj)
            if removeSet.contains(wrapped) {
                removeSet.remove(wrapped)  // unchanged relation; neither add nor remove
            } else {
                addSet.insert(wrapped)  // actually new
            }
        }

        for objRemove in removeSet {
            if added.contains(objRemove) {
                added.remove(objRemove)  // remove after add: cancel add
            } else {
                removed.insert(objRemove)  // actually remove
            }
        }

        for objAdd in addSet {
            if removed.contains(objAdd) {
                removed.remove(objAdd)  // add after remove: cancel remove
            } else {
                added.insert(objAdd)  // actually add
            }
        }

        collectionResolved!.replaceSubrange(subrange, with: newElements)
    }

    // Default removeAll() does a `self = Self()` which must be avoided (see attention comment above):
    // https://github.com/apple/swift/blob/923b1fbedf46022fc1dc0cccf889db88e2e13465 - URL continues in next line -
    // /stdlib/public/core/RangeReplaceableCollection.swift#L644

    // To do: can we officially `override` without compiler complaining?
    /// - Parameter keepCapacity: ignored in this implementation,
    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        replaceSubrange(startIndex..<endIndex, with: EmptyCollection())
    }

    // Default removeAll() reassigns `self` which must be avoided (see attention comment above)
    // To do: can we officially `override` without compiler complaining?
    public func removeAll(where shouldBeRemoved: (ReferencedType) throws -> Bool) rethrows {
        var index = startIndex
        while index < endIndex {
            if try shouldBeRemoved(self[index]) {
                replaceSubrange(index..<(index + 1), with: EmptyCollection())  // subject to optimization
            } else {
                index += 1
            }
        }
    }
}

// MARK: - Description

extension ToMany: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        if resolved {
            return "\(collection)"
        } else {
            return "(unresolved)"
        }
    }
}

extension ToMany: CustomDebugStringConvertible {
    /// :nodoc:
    public var debugDescription: String {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        let mirror = Mirror(reflecting: self)
        if resolved {
            return "\(mirror.subjectType)(\(collection))"
        } else {  // Do not resolve
            return "\(mirror.subjectType)(unresolved)"
        }
    }
}

extension ToMany {
    /// Helper object to provide custom comparison to entities based on ID,
    /// so we can keep a Set of entities.
    /// Note: this can be tricked by adding a new object (ID 0) which is then put (ID set to non-zero value);
    ///       e.g. add an object twice with different IDs or remove an object (ID!=0) that was added before (ID==0).
    ///       For now, trusting that users do not do such things (🙈).
    struct IdComparableReferencedType: Hashable, Comparable {
        static func < (lhs: ToMany<S>.IdComparableReferencedType, rhs: ToMany<S>.IdComparableReferencedType) -> Bool {
            let lhsId = lhs.entityId
            let rhsId = rhs.entityId
            if lhsId == 0 && rhsId == 0 {  // For new objects use object identity
                return ObjectIdentifier(lhs.entity as AnyObject) < ObjectIdentifier(rhs.entity as AnyObject)
            } else {
                return lhsId < rhsId
            }
        }

        let entity: ReferencedType

        var entityId: Id {
            return ReferencedType.entityBinding.entityId(of: entity)
        }

        func hash(into hasher: inout Hasher) {
            let id = entityId
            hasher.combine(id)
            if id == 0 {
                hasher.combine((ObjectIdentifier(entity as AnyObject)))
            }
        }

        static func == (lhs: ToMany<S>.IdComparableReferencedType, rhs: ToMany<S>.IdComparableReferencedType)
                        -> Bool {
            let lhsId: Id = lhs.entityId
            let rhsId = rhs.entityId
            if lhsId == 0 && rhsId == 0 {  // For new objects: use object identity
                return lhs.entity as AnyObject === rhs.entity as AnyObject
            } else {
                return lhsId == rhsId
            }
        }
    }
}

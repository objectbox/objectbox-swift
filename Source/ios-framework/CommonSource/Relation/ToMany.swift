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

// Helper class so we can have a lazy property and clear it to initialize it again.
/// :nodoc:
internal struct ResolverAndCollection<ReferencedType> {
    lazy var collection: [ReferencedType] = {
        return resolver()
    }()
    let resolver: (() -> [ReferencedType])
    
    init(_ resolver: @escaping () -> [ReferencedType]) {
        self.resolver = resolver
    }
}


// Of the form `ToMany<OtherEntity>`. Initialize with `nil` when you define properties.
// The codegen uses the `relation()` and `backlink()` static factory methods to create instances.
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
    
    enum RelationInfo {
        case empty
        case toOneBacklink(propertyId: obx_schema_id, /*referencedId: Id,*/ owningId: Id)
        case toMany(relationId: obx_schema_id, referencedId: Id)
        case toManyBacklink(relationId: obx_schema_id, owningId: Id)
    }
    
    private let info: RelationInfo
    private var owningBox: OpaquePointer? /* OBX_box */ // nil if entity has never been persisted.
    private var referencedBox: Box<ReferencedType>?     // nil if entity has never been persisted.
    // Lock for resolverAndCollection, added, removed.
    private var relationCacheLock = DispatchSemaphore(value: 1)
    // Must take out relationCacheLock to access:
    private var resolverAndCollection: ResolverAndCollection<ReferencedType>
    private var added = Set<IdComparableReferencedType>() // Must take out relationCacheLock to access.
    private var removed = Set<IdComparableReferencedType>() // Must take out relationCacheLock to access.
    
    /// Initialize an empty ToMany relation.
    ///
    /// Use this during object creation. The actual `ToMany` initialization with resolvable
    /// backlinks happens in `ToMany.relation(sourceBox:sourceId:targetBox:relationId:)`,
    /// `ToMany.backlink(sourceBox:sourceProperty:targetId:)` etc. which are
    /// called by the code generator.
    public init(nilLiteral: ()) {
        self.resolverAndCollection = ResolverAndCollection({ [] })
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
        self.resolverAndCollection = ResolverAndCollection({
            do {
                return try sourceBox
                    .backlinkIds(propertyId: sourceProperty.propertyId, entityId: targetId.value)
                    .compactMap { try sourceBox.get(id: $0.value) }
            } catch {
                fatalError("Error resolving backlinks \(error).")
            }
        })
        self.referencedBox = sourceBox
        self.info = .toOneBacklink(propertyId: sourceProperty.propertyId, owningId: targetId.value)
    }
    
    internal init<OwningType>(sourceId: EntityId<OwningType>,
                              targetBox: Box<ReferencedType>,
                              relationId: obx_schema_id) {
        self.resolverAndCollection = ResolverAndCollection({
            // Entity hasn't been written yet and has no array? It's empty.
            guard sourceId.value != 0 else { return [] }
            do {
                let ids: [ReferencedType.EntityBindingType.IdType] = try targetBox.relationTargetIds(
                    relationId: relationId,
                    sourceId: sourceId.value,
                    targetType: ReferencedType.self)
                return try ids.compactMap { try targetBox.get(id: $0.value) }
            } catch {
                fatalError("Error resolving standalone relation \(error).")
            }
        })
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
        self.resolverAndCollection = ResolverAndCollection({
            // Entity hasn't been written yet and has no array? It's empty.
            guard targetId.value != 0 else { return [] }
            do {
                return try sourceBox
                    .relationSourceIds(relationId: relationId, targetId: targetId.value, targetType: OwningType.self)
                    .compactMap { try sourceBox.get($0.value) }
            } catch {
                fatalError("Error resolving standalone backlinks \(error).")
            }
        })
    }
    
    /// Discard the cached list of entities in this relation.
    /// The next time you access this relation's entities, it will re-load the current state from the database.
    public func reset() {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        resolverAndCollection = ResolverAndCollection(resolverAndCollection.resolver)
    }
    
    /// - Important: Must lock relationCacheLock to call this.
    internal func applyToOneBacklinkToDb(propertyId: obx_schema_id, owningId: Id) throws {
        for currEntity in removed {
            ReferencedType.entityBinding.setToOneRelation(propertyId, of: currEntity.entity, to: nil)
        }
        for currEntity in added {
            ReferencedType.entityBinding.setToOneRelation(propertyId, of: currEntity.entity, to: owningId)
        }
        try added.forEach { try referencedBox?.put($0.entity) }
        try removed.forEach { try referencedBox?.put($0.entity) }
    }
    
    /// - Important: Must lock relationCacheLock to call this.
    internal func applyToManyToDb(relationId: obx_schema_id, referencedId: Id) throws {
        guard let owningBox = owningBox else { return }
        if referencedId == 0 {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Referenced object hasn't been put yet.")
        }
        for currEntity in removed {
            if currEntity.entityId == 0 {
                throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Owning object hasn't been put yet.")
            }
            try check(error: obx_box_rel_remove(owningBox, relationId, currEntity.entityId, referencedId))
        }
        for currEntity in added {
            if currEntity.entityId == 0 {
                throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Owning object hasn't been put yet.")
            }
            try check(error: obx_box_rel_put(owningBox, relationId, referencedId, currEntity.entityId))
        }
    }
    
    /// - Important: Must lock relationCacheLock to call this.
    internal func applyToManyBacklinkToDb(relationId: obx_schema_id, owningId: Id) throws {
        guard let referencedBox = referencedBox else { return }
        for currEntity in removed {
            try referencedBox.removeRelation(relationId: relationId,
                                             owningId: owningId, referencedId: currEntity.entityId)
        }
        for currEntity in added {
            try referencedBox.putRelation(relationId: relationId,
                                          owningId: owningId, referencedId: currEntity.entityId)
        }
    }
    
    /// Apply changes made to this ToMany relation.
    /// 
    /// When you edit a ToMany, it first just modifies the relation in RAM, to let you run algorithms on it that would
    /// otherwise cause hundreds of transactions. Then you can call this method to actually write to the database.
    ///
    /// - Note: If this ToMany is a backlink for a ToOne, the entire entity containing the ToOne will be written to
    /// the database in result to this call.
    public func applyToDb() throws {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        if case .toOneBacklink(let propertyId, let owningId) = info,
            let referencedBox = referencedBox {
            if owningId == 0 {
                throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Owning entity of backlink hasn't been "
                    + "put yet.")
            }
            try referencedBox.store.runInTransaction {
                try applyToOneBacklinkToDb(propertyId: propertyId, owningId: owningId)
            }
        } else if let referencedBox = referencedBox {
            try referencedBox.store.runInTransaction {
                if case .toManyBacklink(let relationId, let owningId) = info {
                    if owningId == 0 {
                        throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Owning entity of backlink hasn't "
                            + "been put yet.")
                    }
                    try applyToManyBacklinkToDb(relationId: relationId, owningId: owningId)
                } else if case .toMany(let relationId, let referencedId) = info {
                    if referencedId == 0 {
                        throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Related entity hasn't "
                            + "been put yet")
                    }
                    try applyToManyToDb(relationId: relationId, referencedId: referencedId)
                }
            }
        } else {
            throw ObjectBoxError.cannotRelateToUnsavedEntities(message: "Must put the entity before you can apply().")
        }
        added.removeAll()
        removed.removeAll()
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
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        return resolverAndCollection.collection.startIndex
    }
    
    /// The collections "past the end" position -- that is, the position one greater
    /// than the last valid subscript argument.
    public var endIndex: Index {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        return resolverAndCollection.collection.endIndex
    }
    
    // swiftlint:disable identifier_name
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than `endIndex`.
    /// - Returns: The index immediately after `i`.
    public func index(after i: Index) -> Index {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        return resolverAndCollection.collection.index(after: i)
    }
    
    /// Returns the position immediately before the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than `startIndex`.
    /// - Returns: The index immediately before `i`.
    public func index(before i: Index) -> Index {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        return resolverAndCollection.collection.index(before: i)
    }
    // swiftlint:enable identifier_name
    /// Enable accessing elements of the relation as e.g. `customer[0]` via array subscript operator.
    public subscript(position: Index) -> ReferencedType {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        return resolverAndCollection.collection[position]
    }
}

extension ToMany: RangeReplaceableCollection {
    public convenience init() {
        self.init(nilLiteral: ())
    }
    
    public func replaceSubrange<C, R>(_ subrange: R, with newElements: __owned C)
        where C: Collection, R: RangeExpression, ReferencedType == C.Element, Index == R.Bound {
            relationCacheLock.wait()
            defer { relationCacheLock.signal() }
            if resolverAndCollection.collection.isEmpty && newElements.isEmpty { return }
            
            let replacedComparableElements = resolverAndCollection.collection[subrange].map {
                return IdComparableReferencedType(entity: $0)
            }
            let newComparableElements = newElements.map { return IdComparableReferencedType(entity: $0) }
            
            newComparableElements.forEach { removed.remove($0) }
            replacedComparableElements.forEach { removed.insert($0) }
            replacedComparableElements.forEach { added.remove($0) }
            newComparableElements.forEach { added.insert($0) }
            
            resolverAndCollection.collection.replaceSubrange(subrange, with: newElements)
    }
}

// MARK: - Description

extension ToMany: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        return "\(resolverAndCollection.collection)"
    }
}

extension ToMany: CustomDebugStringConvertible {
    /// :nodoc:
    public var debugDescription: String {
        relationCacheLock.wait()
        defer { relationCacheLock.signal() }
        let mirror = Mirror(reflecting: self)
        return "\(mirror.subjectType)(\(resolverAndCollection.collection))"
    }
}

extension ToMany {
    /// Helper object to provide custom comparison to entities based on ID,
    /// so we can keep a Set of entities.
    struct IdComparableReferencedType: Hashable {
        let entity: ReferencedType
        
        var entityId: Id {
            return ReferencedType.entityBinding.entityId(of: entity)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(entityId)
        }
        
        static func == (lhs: ToMany<S>.IdComparableReferencedType, rhs: ToMany<S>.IdComparableReferencedType)
            -> Bool {
                return lhs.entityId == rhs.entityId
        }
    }
}

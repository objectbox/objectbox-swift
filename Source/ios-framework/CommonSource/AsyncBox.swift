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

/// AsyncBox is a class that lets you asynchronously perform basic database write
/// operations.
/// Your program can just fire off these operations and forget about them, and they'll be
/// executed for you on a background thread, without blocking your UI or the like until writes have
/// completed.
/// - important: AsyncBox does not report errors that occur in asynchronous execution.
public class AsyncBox<E: EntityInspectable & __EntityRelatable>
where E == E.EntityBindingType.EntityType {
    /// Type of class this box is for.
    public typealias EntityType = E
    
    internal var cAsyncBox: OpaquePointer?
    private var ownsAsyncBox = true
    private weak var box: Box<EntityType>!

    internal init(box: Box<EntityType>, unownedAsyncBox: OpaquePointer?) {
        self.box = box
        self.cAsyncBox = unownedAsyncBox
        self.ownsAsyncBox = false
    }
    
    /// Create an async box for the given Box. Usually, you will want to just use Box.async to get a shared
    /// AsyncBox to place requests on.
    public init(box: Box<EntityType>, enqueueTimeout: TimeInterval) {
        self.box = box
		self.cAsyncBox = obx_async_create(box.cBox, UInt64(enqueueTimeout * 1000.0))
        self.ownsAsyncBox = true
    }

    deinit {
        if ownsAsyncBox, let cAsyncBox = self.cAsyncBox {
            obx_async_close(cAsyncBox)
            self.cAsyncBox = nil
        }
    }
    
    internal func putOne(_ entity: EntityType, binding: EntityType.EntityBindingType,
                         flatBuffer: FlatBufferBuilder, mode: PutMode) throws -> Id {
        flatBuffer.isCollecting = true
        defer { flatBuffer.clear(); flatBuffer.isCollecting = false }
        
        let entityId = binding.entityId(of: entity)
        let actualId = obx_box_id_for_put(box.cBox, entityId)
        try binding.collect(fromEntity: entity, id: actualId, propertyCollector: flatBuffer, store: box.store)
        flatBuffer.ensureStarted()
        let data = try flatBuffer.finish()
        try checkLastError(obx_async_put5(cAsyncBox, actualId, data.data, data.size, OBXPutMode(mode.rawValue)))

        return actualId
    }
    
    /// Queue up the given entity to be put asynchronously. If the entity hasn't been assigned a nonzero ID yet,
    /// this will assign it a new ID. It will also return the entity's ID. If the entity is a class, not a struct,
    /// it will also adjust the entity's id property to match the returned ID.
    @discardableResult
    public func put(_ entity: EntityType, mode: PutMode = .put) throws -> EntityId<EntityType> {
        let binding = EntityType.entityBinding
        let flatBuffer = FlatBufferBuilder.dequeue()
        defer { FlatBufferBuilder.return(flatBuffer) }
        
        let entityId = try putOne(entity, binding: binding, flatBuffer: flatBuffer, mode: mode)
        binding.setEntityIdUnlessStruct(of: entity, to: entityId)
        return EntityId(entityId)
    }
    
    /// Queue up the given entities to be put asynchronously. If an entity hasn't been assigned a nonzero ID yet,
    /// this will assign it a new ID. It will also return all entities' IDs. If the entity is a class, not a struct,
    /// it will also adjust each entity's ID property to match the returned ID.
    /// - returns: the IDs the entities were put under, so you can e.g. assign them to your structs manually.
    @discardableResult
    public func put<C: Collection>(_ entities: C, mode: PutMode = .put) throws -> [EntityId<EntityType>]
        where C.Element == EntityType {
            let binding = EntityType.entityBinding
            let flatBuffer = FlatBufferBuilder.dequeue()
            defer { FlatBufferBuilder.return(flatBuffer) }
            // swiftlint:disable opening_brace
            return try [EntityId<EntityType>](unsafeUninitializedCapacity: entities.count)
            { ptr, initializedCount in
                initializedCount = 0
                for entity in entities {
                    let entityId = try putOne(entity, binding: binding, flatBuffer: flatBuffer, mode: mode)
                    binding.setEntityIdUnlessStruct(of: entity, to: entityId)
                    ptr[initializedCount] = EntityId(entityId)
                    initializedCount += 1
                }
            }
            // swiftlint:enable opening_brace
    }
    
    /// :nodoc:
    @discardableResult
    public func put(_ entities: [EntityType], mode: PutMode = .put) throws -> [EntityId<EntityType>] {
            let binding = EntityType.entityBinding
            let flatBuffer = FlatBufferBuilder.dequeue()
            defer { FlatBufferBuilder.return(flatBuffer) }
            // swiftlint:disable opening_brace
            return try [EntityId<EntityType>](unsafeUninitializedCapacity: entities.count)
            { ptr, initializedCount in
                initializedCount = 0
                for entity in entities {
                    let entityId = try putOne(entity, binding: binding, flatBuffer: flatBuffer, mode: mode)
                    binding.setEntityIdUnlessStruct(of: entity, to: entityId)
                    ptr[initializedCount] = EntityId(entityId)
                    initializedCount += 1
                }
            }
            // swiftlint:enable opening_brace
    }

    /// Version of `put([EntityType])` that is faster because it uses ContiguousArray
    @discardableResult
    public func put(_ entities: ContiguousArray<EntityType>, mode: PutMode = .put) throws
        -> ContiguousArray<EntityId<EntityType>> {
            let binding = EntityType.entityBinding
            let flatBuffer = FlatBufferBuilder.dequeue()
            defer { FlatBufferBuilder.return(flatBuffer) }
            // swiftlint:disable opening_brace
            return try ContiguousArray<EntityId<EntityType>>(unsafeUninitializedCapacity: entities.count)
            { ptr, initializedCount in
                initializedCount = 0
                for entity in entities {
                    let entityId = try putOne(entity, binding: binding, flatBuffer: flatBuffer, mode: mode)
                    binding.setEntityIdUnlessStruct(of: entity, to: entityId)
                    ptr[initializedCount] = EntityId(entityId)
                    initializedCount += 1
                }
            }
            // swiftlint:enable opening_brace
    }

    /// Queue up the given entities (provided as individual parameters, not as an array) to be put
    /// asynchronously. If an entity hasn't been assigned a nonzero ID yet, this will assign it a new ID. It will also
    /// return all entities' IDs. If the entity is a class, not a struct, it will also adjust each entity's ID property
    /// to match the returned ID.
    /// - returns: the IDs the entities were put under, so you can e.g. assign them to your structs manually.
    @discardableResult
    public func put(_ entities: EntityType..., mode: PutMode = .put) throws -> [EntityId<EntityType>] {
        return try put(entities, mode: mode)
    }
        
    /// Queue up the entity with the given ID to be deleted from the database asynchronously.
    public func remove(_ entityId: EntityId<EntityType>) throws {
        try checkLastError(obx_async_remove(cAsyncBox, entityId.value))
    }

    /// Queue up the entity with the given ID to be deleted from the database asynchronously.
    public func remove<I: UntypedIdBase>(_ entityId: I) throws {
        try checkLastError(obx_async_remove(cAsyncBox, entityId.value))
    }

    /// Queue up the given entity to be deleted from the database asynchronously.
    public func remove(_ entity: EntityType) throws {
        try checkLastError(obx_async_remove(cAsyncBox, EntityType.entityBinding.entityId(of: entity)))
    }

    /// Queue up the given entities to be deleted from the database asynchronously.
    public func remove<C: Collection>(_ entities: C) throws
        where C.Element == EntityType {
        let binding = EntityType.entityBinding
        for entity in entities {
            try checkLastError(obx_async_remove(cAsyncBox, binding.entityId(of: entity)))
        }
    }

    /// Queue up the given entities (provided as individual parameters, not as an array) to be deleted
    /// from the database asynchronously.
    public func remove(_ entities: EntityType...) throws {
        try remove(entities)
    }
    
    /// Queue up the entities with the given IDs to be deleted from the database asynchronously.
    public func remove<C: Collection>(_ entityIDs: C) throws
        where C.Element == EntityId<EntityType> {
        for entityId in entityIDs {
            try checkLastError(obx_async_remove(cAsyncBox, entityId.value))
        }
    }
    
    /// Queue up the entities with the given IDs to be deleted from the database asynchronously.
    public func remove<I: UntypedIdBase, C: Collection>(_ entityIDs: C) throws
        where C.Element == I {
        for entityId in entityIDs {
            try checkLastError(obx_async_remove(cAsyncBox, entityId.value))
        }
    }
    
    /// Queue up the entities with the given IDs (provided as individual parameters, not as an array)
    /// to be deleted from the database asynchronously.
    public func remove(_ entityIDs: EntityId<EntityType>...) throws {
        try remove(entityIDs)
    }
    
    /// Queue up the entities with the given IDs (provided as individual parameters, not as an array)
    /// to be deleted from the database asynchronously.
    public func remove<I: UntypedIdBase>(_ entityIDs: I...) throws {
        try remove(entityIDs)
    }
}

extension Store {
    // MARK: Async helpers

    /// Wait until anything that's been submitted so far for asynchronous execution on any
    /// AsyncBox in this store has been processed.
    @discardableResult
    public func awaitAsyncSubmitted() -> Bool {
        return obx_store_await_async_submitted(cStore)
    }

    /// Wait for the async queue used by all AsyncBoxes in this store to become idle
    /// because nothing has been queued up for a while.
    @discardableResult
    public func awaitAsyncCompleted() -> Bool {
        return obx_store_await_async_completion(cStore)
    }
}

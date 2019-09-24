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

// Wrapper for OBX_box that provides a native Swift API.

/// A box to store objects of a particular type.
///
/// Thread-safe.
public class Box<E: EntityInspectable & __EntityRelatable>: CustomDebugStringConvertible
where E == E.EntityBindingType.EntityType {
    
    /// The object type this box is managing.
    public typealias EntityType = E
    
    internal let cBox: OpaquePointer /* OBX_box */
    internal let store: Store
    
    internal init(store: Store) {
        self.store = store
        self.cBox = obx_box(store.cStore, EntityType.entityInfo.entitySchemaId)
    }
    
    // MARK: Box Introspection
    
    /// Indicates whether there are any objects stored inside the box.
    public func isEmpty() throws -> Bool { return try count(limit: 1) == 0 }

    /// Get an async box on which you can enqueue requests asynchronously.
    private(set) public lazy var async: AsyncBox<E> = {
        return AsyncBox(box: self, unownedAsyncBox: obx_async(self.cBox))
    }()
    
    /// Returns the number of objects in this box, up to an optional maximum.
    ///
    /// - Parameter limit: Maximum value to count up to, or 0 for unlimited count.
    /// - Returns: The count of all stored objects in this box or the given `limit`, whichever is lower.
    public func count(limit: Int = 0) throws -> Int {
        var result: UInt64 = 0
        try checkLastError(obx_box_count(cBox, UInt64(limit), &result))
        return Int(result) // Return as Int because that's what Swift Standard lib uses for arrays.
    }
    
    /// Find out whether there is an object with the given ID in this box.
    ///
    /// - Parameter entityId: ID of the object.
    /// - Returns: true if an object with this ID exists, false otherwise.
    public func contains(_ entityId: EntityType.EntityBindingType.IdType) throws -> Bool {
        var result = false
        try checkLastError(obx_box_contains(cBox, entityId.value, &result))
        return result
    }
    
    /// Find out whether objects with the given ID exist in this box.
    ///
    /// - Parameter entityIds: ID of the object.
    /// - Returns: true if all objects specified exist.
    public func contains(_ ids: [EntityType.EntityBindingType.IdType]) throws -> Bool {
        var result = false

        var entityIds = ids.map { currId -> Id in currId.value }
        let numEntities = entityIds.count
        try entityIds.withContiguousMutableStorageIfAvailable { cArray -> Void in
            guard let safePtr = cArray.baseAddress else { result = false; return }
            var obxArray = OBX_id_array(ids: safePtr, count: numEntities)
            try checkLastError(obx_box_contains_many(cBox, &obxArray, &result))
        }

        return result
    }
}

// MARK: Persisting Objects

extension Box {
    
    /// Puts the given object in the box (aka persisting it). If the entity hadn't been persisted yet, it will be
    /// assigned an ID.
    ///
    /// - Parameter entity: Object to persist.
    /// - Returns: ID of the object after persistence. If `entity` was persisted before, it's the same as its ID.
    ///   If `entity` is a new object, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func put(_ entity: EntityType) throws -> EntityType.EntityBindingType.IdType {
        let binding = EntityType.entityBinding
        let flatBuffer = FlatBufferBuilder.dequeue()
        defer { FlatBufferBuilder.return(flatBuffer) }
        
        var writtenId: Id = 0
        
        try store.obx_runInTransaction { swiftTx in
            let cursor = obx_cursor(swiftTx.cTransaction, EntityType.entityInfo.entitySchemaId)
            defer { obx_cursor_close(cursor) }
            
            writtenId = try putOne(entity, binding: binding, flatBuffer: flatBuffer, cursor: cursor)
            binding.postPut(fromEntity: entity, id: writtenId, store: store)
        }
        binding.setEntityIdUnlessStruct(of: entity, to: writtenId)
        
        return EntityType.EntityBindingType.IdType(writtenId)
    }
    
    internal func putOne(_ entity: EntityType, binding: EntityType.EntityBindingType, flatBuffer: FlatBufferBuilder,
                         cursor: OpaquePointer!) throws -> Id {
        flatBuffer.isCollecting = true
        defer { flatBuffer.clear(); flatBuffer.isCollecting = false }
        
        let actualId = obx_cursor_id_for_put(cursor, binding.entityId(of: entity))
        binding.collect(fromEntity: entity, id: actualId, propertyCollector: flatBuffer, store: store)
        flatBuffer.ensureStarted()
        let data = try flatBuffer.finish()
        try checkLastError(obx_cursor_put(cursor, actualId, data.data, data.size, false))
        
        return actualId
    }
    
    /// Puts the given entities in a box using a single transaction. Any entities that hadn't been persisted yet will be
    /// assigned an ID. For classes, the entity's ID will be set to match any newly-assigned IDs.
    /// For structs, you will have to extract the IDs from the returned array of IDs and assign it to your entity.
    /// If an error occurs putting one of the entities, only the entities up to that entity will be put and an error
    /// thrown.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Returns: List of IDs of the entities were written to.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func put(_ entities: [EntityType]) throws -> [EntityType.EntityBindingType.IdType] {
        if entities.isEmpty {
            // Short-cut, we don't need a TX
            return []
        }
        var result = [EntityType.EntityBindingType.IdType]()
        try store.obx_runInTransaction { swiftTx in
            let binding = EntityType.entityBinding
            let flatBuffer = FlatBufferBuilder.dequeue()
            defer { FlatBufferBuilder.return(flatBuffer) }
            
            let cursor = obx_cursor(swiftTx.cTransaction, EntityType.entityInfo.entitySchemaId)
            defer { obx_cursor_close(cursor) }
            
            for entity in entities {
                let writtenId = try putOne(entity, binding: binding, flatBuffer: flatBuffer,
                                           cursor: cursor)
                binding.postPut(fromEntity: entity, id: writtenId, store: store)
                binding.setEntityIdUnlessStruct(of: entity, to: writtenId)
                result.append(EntityType.EntityBindingType.IdType(writtenId))
            }
        }
        return result
    }
    
    internal func put(_ relatedEntity: ToOne<EntityType>) throws -> EntityType.EntityBindingType.IdType? {
        guard let entity = relatedEntity.target else { return nil }
        return try put(entity)
    }
}

// MARK: Reading Objects

extension Box {
    
    /// This function *must* be called inside a valid transaction. The transaction guarantees that the pointers returned
    /// by obx_box_get() stay valid until we've actually copied them.
    internal func getOne(_ entityId: Id, binding: EntityType.EntityBindingType,
                         flatBuffer: inout FlatBufferReader) throws -> EntityType? {
        var ptr: UnsafeMutableRawPointer?
        var size: Int = 0
        let err = obx_box_get(cBox, entityId, &ptr, &size)
        if err == OBX_NOT_FOUND { obx_last_error_clear(); return nil }
        try checkLastError(err)
        guard let safePtr = ptr else { return nil }
        flatBuffer.setCurrentlyReadTableBytes(UnsafeRawPointer(safePtr))
        return binding.createEntity(entityReader: flatBuffer, store: store)
    }
    
    /// Get the stored objects for the given ID.
    ///
    /// - Parameter entityId: ID of the object.
    /// - Returns: The entity, if an object with `entityId` was found, `nil` otherwise.
    internal func get(id entityId: Id) throws -> EntityType? {
        return try store.obx_runInReadOnlyTransaction { _ in
            let binding = EntityType.entityBinding
            var flatBuffer = FlatBufferReader()
            
            return try getOne(entityId.value, binding: binding, flatBuffer: &flatBuffer)
        }
    }
    
    /// Get the stored objects for the given ID.
    ///
    /// - Parameter entityId: ID of the object.
    /// - Returns: The entity, if an object with `entityId` was found, `nil` otherwise.
    public func get<I: UntypedIdBase>(_ entityId: I) throws -> EntityType? {
        return try get(id: entityId.value)
    }
    
    /// Get the stored objects for the given ID.
    ///
    /// - Parameter entityId: ID of the object.
    /// - Returns: The entity, if an object with `entityId` was found, `nil` otherwise.
    public func get(_ entityId: EntityId<EntityType>) throws -> EntityType? {
        return try get(id: entityId.value)
    }
    
    /// Gets entities from the box for each ID in `entityIds`.
    ///
    /// - Parameter entityIds: Object IDs to map to objects.
    /// - Returns: Dictionary of all `entityIds` and the corresponding objects.
    ///   Nothing is added to the dictionary for entities that can't be found.
    public func dictionaryWithEntities(forIds entityIds: [EntityId<EntityType>]) throws
        -> [EntityId<EntityType>: EntityType] {
            return try dictionaryWithEntities(forIdBases: entityIds)
    }

    /// Gets entities from the box for each ID in `entityIds`.
    ///
    /// - Parameter entityIds: Object IDs to map to objects.
    /// - Returns: Dictionary of all `entityIds` and the corresponding objects.
    ///   Nothing is added to the dictionary for entities that can't be found.
    public func dictionaryWithEntities<I: UntypedIdBase>(forIds entityIds: [I]) throws
        -> [I: EntityType] {
            return try dictionaryWithEntities(forIdBases: entityIds)
    }

    /// Gets entities from the box for each ID in `entityIds`.
    ///
    /// - Parameter entityIds: Object IDs to map to objects.
    /// - Returns: Dictionary of all `entityIds` and the corresponding objects.
    ///   Nothing is added to the dictionary for entities that can't be found.
    private func dictionaryWithEntities<I: IdBase>(forIdBases entityIds: [I]) throws
        -> [I: EntityType] {
            var result = [I: EntityType]()
            
            try store.obx_runInReadOnlyTransaction { _ in
                let binding = EntityType.entityBinding
                var flatBuffer = FlatBufferReader()
                
                for entityId in entityIds {
                    if let entity = try getOne(entityId.value, binding: binding, flatBuffer: &flatBuffer) {
                        result[entityId] = entity
                    }
                }
            }
            
            return result
    }
    
    /// Gets all objects from the box.
    /// - Throws: ObjectBoxError
    /// - Returns: All stored Objects in this Box.
    public func find() throws -> [EntityType] {
        var result = [EntityType]()
        
        try store.obx_runInReadOnlyTransaction { _ in
            guard let bytesArray = obx_box_get_all(cBox) else { try checkLastError(); return }
            defer { obx_bytes_array_free(bytesArray) }
            result = try readAll(bytesArray.pointee)
        }
        
        return result
    }
    
    /// Gets all objects from the box.
    ///
    /// - Returns: All stored Objects in this Box.
    public func all() throws -> [EntityType] {
        var result = [EntityType]()
        
        result = try find()
        
        return result
    }
    
    internal func readAll(_ bytesArray: OBX_bytes_array) throws -> [EntityType] {
        var result = [EntityType]()
        result.reserveCapacity(bytesArray.count)
        
        try store.obx_runInReadOnlyTransaction { _ in
            let binding = EntityType.entityBinding
            var flatBuffer = FlatBufferReader()
            
            for dataIndex in 0 ..< bytesArray.count {
                flatBuffer.setCurrentlyReadTableBytes(bytesArray.bytes[dataIndex].data)
                let entity = binding.createEntity(entityReader: flatBuffer, store: store)
                result.append(entity)
            }
        }
        
        return result
    }
    
}

// MARK: Visit

extension Box {
    
    // The "visit" APIs are the ones that can be aborted and are more like ObjectBox's C API, the "forXXX" APIs are
    // more like Swift's forEach and can't be aborted.
    
    /// Iterate over all objects in this box, calling the given closure with each object.
    /// This lazily creates one object after the other and hands them to you, and if you do not hold on to the objects,
    /// will free their memory once done.
    /// - Parameter visitor: A closure that is called for each object in this box. Return true to keep going, false to
    ///                      abort the loop. Exceptions thrown by the closure are re-thrown.
    public func visit(_ visitor: ((EntityType) throws -> Bool)) throws {
        try withoutActuallyEscaping(visitor) { callback in
            let context: InstanceVisitorBase = InstanceVisitor(type: EntityType.self, store: store,
                                                               visitor: callback)
            
            try checkLastError(obx_box_visit_all(cBox, { (contextPtr, ptr, size) -> Bool in
                guard let safePtr = ptr else { return false }
                let context: InstanceVisitorBase = Unmanaged.fromOpaque(contextPtr!).takeUnretainedValue()
                return context.visit(ptr: safePtr, size: size) && context.userError == nil
            }, Unmanaged.passUnretained(context).toOpaque()))
            
            if let userError = context.userError {
                throw userError
            }
        }
    }
    
    /// Iterate over all objects in this box, calling the given closure with each object.
    /// This lazily creates one object after the other and hands them to you, and if you do not hold on to the objects,
    /// will free their memory once done.
    /// - Parameter visitor: A closure that is called for each object in this box. Exceptions thrown by the closure are
    ///                      re-thrown.
    public func forEach(_ visitor: ((EntityType) throws -> Void)) throws {
        try self.visit { entity in
            try visitor(entity)
            return true
        }
    }
    
    /// Iterate over the objects in this box with the given IDs, calling the given closure with each object.
    /// This lazily creates one object after the other and hands them to you, and if you do not hold on to the objects,
    /// will free their memory once done.
    /// - Parameter visitor: A closure that is called for each object requested. If an object with the requested ID
    ///                      can't be found, you get a callback with a NIL entity. Exceptions thrown by the closure are
    ///                      re-thrown.
    public func `for`(_ ids: [EntityType.EntityBindingType.IdType], in visitor: ((EntityType?) throws -> Void)) throws {
        try self.visit(ids) { entity in
            try visitor(entity)
            return true
        }
    }
    
    /// Iterate over the objects in this box with the given IDs, calling the given closure with each object.
    /// This lazily creates one object after the other and hands them to you, and if you do not hold on to the objects,
    /// will free their memory once done.
    /// - Parameter visitor: A closure that is called for each object requested. If an object with the requested ID
    ///                      can't be found, you get a callback with a NIL entity. Exceptions thrown by the closure are
    ///                      re-thrown.
    public func visit(_ ids: [EntityType.EntityBindingType.IdType], in visitor: ((EntityType?) throws -> Bool)) throws {
        try withoutActuallyEscaping(visitor) { callback in
            let context: InstanceVisitorBase = InstanceVisitor(type: EntityType.self, store: store,
                                                               optionalVisitor: callback)
            
            var entityIds = ids.map { currId -> Id in currId.value }
            let numEntities = entityIds.count
            try entityIds.withContiguousMutableStorageIfAvailable { cArray -> Void in
                guard let safePtr = cArray.baseAddress else { return }
                var obxArray = OBX_id_array(ids: safePtr, count: numEntities)
                
                try checkLastError(obx_box_visit_many(cBox, &obxArray, { (contextPtr, ptr, size) -> Bool in
                    let context: InstanceVisitorBase = Unmanaged.fromOpaque(contextPtr!).takeUnretainedValue()
                    return context.visit(ptr: ptr, size: size) && context.userError == nil
                }, Unmanaged.passUnretained(context).toOpaque()))
            }
            
            if let userError = context.userError {
                throw userError
            }
        }
    }    
}

// MARK: Removing Objects

extension Box {
    
    /// Removes (deletes) the Object by its ID.
    ///
    /// - Parameter entityId: ID of the object to delete.
    /// - Returns: false if `entityId` is 0, true if the object was successfully deleted.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func remove<I: UntypedIdBase>(_ entityId: I) throws -> Bool {
        guard entityId.value != 0 else { return false }
        try check(error: obx_box_remove(cBox, entityId.value))
        return true
    }

    /// Removes (deletes) the Object by its ID.
    ///
    /// - Parameter entityId: ID of the object to delete.
    /// - Returns: false if `entityId` is 0, true if the object was successfully deleted.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func remove(_ entityId: EntityId<EntityType>) throws -> Bool {
        guard entityId.value != 0 else { return false }
        try check(error: obx_box_remove(cBox, entityId.value))
        return true
    }

    /// Removes (deletes) the given Object.
    ///
    /// - Parameter entity: Object to delete.
    /// - Returns: false if the object was never persisted, true if the object was successfully deleted.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func remove(_ entity: EntityType) throws -> Bool {
        guard entity._id.value != 0 else { return false }
        try check(error: obx_box_remove(cBox, entity._id.value))
        return true
    }
    
    /// Removes (deletes) the given objects in a single transaction.
    ///
    /// It is valid to pass objects here that haven't been persisted yet.
    ///
    /// - Parameter entities: Objects to delete.
    /// - Returns: Count of objects that were removed.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func remove(_ entities: [EntityType]) throws -> UInt64 {
        var result: UInt64 = 0
        
        var entityIds = entities.compactMap { ($0._id.value != 0) ? $0._id.value : nil }
        let numEntities = entityIds.count
        try entityIds.withContiguousMutableStorageIfAvailable { cArray -> Void in
            guard let safePtr = cArray.baseAddress else { result = 0; return }
            var obxArray = OBX_id_array(ids: safePtr, count: numEntities)
            try check(error: obx_box_remove_many(cBox, &obxArray, &result))
        }
        
        return result
    }
    
    /// Removes (deletes) the objects with the given IDs in a single transaction.
    ///
    /// It is valid to pass IDs of objects here that haven't been persisted yet (i.e. any 0 ID  is skipped). If an
    /// entity is passed whose ID doesn't exist anymore, only the entities up to that entity will be removed.
    ///
    /// - Parameter entities: Objects to delete.
    /// - Returns: Count of objects that were removed.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func remove<I: UntypedIdBase>(_ entityIDs: [I]) throws -> UInt64 {
        var result: UInt64 = 0
        
        var entityIds = entityIDs.map { currId -> Id in currId.value }
        let numEntities = entityIds.count
        try entityIds.withContiguousMutableStorageIfAvailable { cArray -> Void in
            guard let safePtr = cArray.baseAddress else { result = 0; return }
            var obxArray = OBX_id_array(ids: safePtr, count: numEntities)
            try checkLastError(obx_box_remove_many(cBox, &obxArray, &result))
        }
        
        return result
    }
    
    /// Removes (deletes) the objects with the given IDs in a single transaction.
    ///
    /// It is valid to pass IDs of objects here that haven't been persisted yet (i.e. any 0 ID  is skipped). If an
    /// entity is passed whose ID doesn't exist anymore, only the entities up to that entity will be removed.
    ///
    /// - Parameter entities: Objects to delete.
    /// - Returns: Count of objects that were removed.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func remove(_ entityIDs: [EntityId<EntityType>]) throws -> UInt64 {
        var result: UInt64 = 0
        
        var entityIds = entityIDs.map { currId -> Id in currId.value }
        let numEntities = entityIds.count
        try entityIds.withContiguousMutableStorageIfAvailable { cArray -> Void in
            guard let safePtr = cArray.baseAddress else { result = 0; return }
            var obxArray = OBX_id_array(ids: safePtr, count: numEntities)
            try checkLastError(obx_box_remove_many(cBox, &obxArray, &result))
        }
        
        return result
    }
    
    /// Removes (deletes) **all** objects in a single transaction.
    ///
    /// - Returns: Count of items that were removed.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func removeAll() throws -> UInt64 {
        var result: UInt64 = 0
        try check(error: obx_box_remove_all(cBox, &result))
        return result
    }
    
    /// :nodoc:
    public var debugDescription: String {
        return "<ObjectBox.Box \(String(describing: EntityType.self))>"
    }
}

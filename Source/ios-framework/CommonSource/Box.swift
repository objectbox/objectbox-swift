//
// Copyright © 2018-2023 ObjectBox Ltd. All rights reserved.
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
        cBox = obx_box(store.cStore, EntityType.entityInfo.entitySchemaId)
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

    /// Find out whether objects with the given IDs exist in this box.
    ///
    /// - Parameter ids: IDs of the objects.
    /// - Returns: true if all objects specified exist.
    public func contains(_ ids: [EntityType.EntityBindingType.IdType]) throws -> Bool {
        var result = true

        try store.obx_runInTransaction(writable: false, { swiftTx in
            let cursor = try Cursor<EntityType>(transaction: swiftTx)

            for currId in ids {
                if try !cursor.contains(currId.value) {
                    result = false
                    return
                }
            }
        })

        return result
    }

    /// Find out whether objects with the given IDs (passed individually, not as an array) exist in this box.
    ///
    /// - Parameter ids: IDs of the objects.
    /// - Returns: true if all objects specified exist.
    public func contains(_ ids: EntityType.EntityBindingType.IdType...) throws -> Bool {
        return try contains(ids)
    }
}

// MARK: Persisting Objects

extension Box {
    /// Puts the given struct in the box (aka persisting it). If the struct hadn't been persisted yet, it will be
    /// assigned an ID, which will be written back to the entity's ID property.
    ///
    /// - Parameter entity: Object to persist.
    /// - Parameter mode: Whether you want to put (insert or update), insert (fail if there is an existing object of
    ///                     the given ID) or update (fail if the object doesn't exist anymore).
    /// - Returns: ID of the object after persistence. If `entity` was persisted before, it's the same as its ID.
    ///   If `entity` is a new object, this is the new ID that was generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func put(_ entity: inout EntityType, mode: PutMode = .put) throws -> EntityType.EntityBindingType.IdType {
        let binding = EntityType.entityBinding
        let flatBuffer = FlatBufferBuilder.dequeue()
        defer { FlatBufferBuilder.return(flatBuffer) }

        var writtenId: Id = 0

        try store.obx_runInTransaction(writable: true, { swiftTx in
            let cursor = try Cursor<EntityType>(transaction: swiftTx)

            writtenId = try putOne(entity, binding: binding, flatBuffer: flatBuffer, mode: mode, cursor: cursor)
            try binding.postPut(fromEntity: entity, id: writtenId, store: store)
        })
        binding.setStructEntityId(of: &entity, to: writtenId)

        return EntityType.EntityBindingType.IdType(writtenId)
    }

    /// Puts the given object in the box (aka persisting it). If the entity hadn't been persisted yet, it will be
    /// assigned an ID, and if the entity is not a struct, the ID will be written back to the entity's ID property.
    /// For a struct, either use the `put(inout EntityType)` variant or assign the returned ID to the ID property
    /// yourself.
    ///
    /// - Parameter entity: Object to persist.
    /// - Parameter mode: Whether you want to put (insert or update), insert (fail if there is an existing object of
    ///                     the given ID) or update (fail if the object doesn't exist anymore).
    /// - Returns: ID of the object after persistence. If `entity` was persisted before, it's the same as its ID.
    ///   If `entity` is a new object, this is the new ID that was generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func put(_ entity: EntityType, mode: PutMode = .put) throws -> EntityType.EntityBindingType.IdType {
        let binding = EntityType.entityBinding
        let flatBuffer = FlatBufferBuilder.dequeue()
        defer { FlatBufferBuilder.return(flatBuffer) }

        var writtenId: Id = 0

        try store.obx_runInTransaction(writable: true, { swiftTx in
            let cursor = try Cursor<EntityType>(transaction: swiftTx)

            writtenId = try putOne(entity, binding: binding, flatBuffer: flatBuffer, mode: mode, cursor: cursor)
            try binding.postPut(fromEntity: entity, id: writtenId, store: store)
        })
        binding.setEntityIdUnlessStruct(of: entity, to: writtenId)

        return EntityType.EntityBindingType.IdType(writtenId)
    }

    internal func putOne(_ entity: EntityType, binding: EntityType.EntityBindingType, flatBuffer: FlatBufferBuilder,
                         mode: PutMode, cursor: Cursor<EntityType>) throws -> Id {
        flatBuffer.isCollecting = true
        defer { flatBuffer.clear(); flatBuffer.isCollecting = false }

        let actualId = cursor.idForPut(entity)
        try binding.collect(fromEntity: entity, id: actualId, propertyCollector: flatBuffer, store: store)
        flatBuffer.ensureStarted()
        let data = try flatBuffer.finish()
        try cursor.put(id: actualId, data: data, mode: mode)

        return actualId
    }

    /// Puts the given entities in a box using a single transaction. Any entities that hadn't been persisted yet will be
    /// assigned an ID. For classes, the entity's ID property will be set to match any newly-assigned IDs.
    /// For structs, use the `put(inout [EntityType])` variant or extract the IDs from the returned array of
    /// IDs and assign them to each entity.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Parameter mode: Whether you want to put (insert or update), insert (fail if there is an existing object of
    ///                     the given ID) or update (fail if the object doesn't exist anymore).
    /// - Returns: List of IDs of the entities were written to.
    /// - Throws: ObjectBoxError errors for database write errors.
    @discardableResult
    public func putAndReturnIDs <C: Collection>(_ entities: C, mode: PutMode = .put) throws
        -> [EntityType.EntityBindingType.IdType]
        where C.Element == EntityType {
            if entities.isEmpty {
                // Short-cut, we don't need a TX
                return []
            }
            // swiftlint:disable opening_brace
            let result = try [EntityType.EntityBindingType.IdType](unsafeUninitializedCapacity: entities.count)
            { ptr, initializedCount in
                try store.obx_runInTransaction(writable: true, { swiftTx in
                    let binding = EntityType.entityBinding
                    let flatBuffer = FlatBufferBuilder.dequeue()
                    defer { FlatBufferBuilder.return(flatBuffer) }

                    let cursor = try Cursor<EntityType>(transaction: swiftTx)

                    initializedCount = 0
                    for entity in entities {
                        let writtenId = try putOne(entity, binding: binding, flatBuffer: flatBuffer,
                                                   mode: mode, cursor: cursor)
                        try binding.postPut(fromEntity: entity, id: writtenId, store: store)
                        binding.setEntityIdUnlessStruct(of: entity, to: writtenId)
                        ptr[initializedCount] = EntityType.EntityBindingType.IdType(writtenId)
                        initializedCount += 1
                    }
                })
            }
            // swiftlint:enable opening_brace
            return result
    }

    /// Puts the given entities in a box using a single transaction. Any entities that hadn't been persisted yet will be
    /// assigned an ID. For classes, the entity's ID property will be set to match any newly-assigned IDs.
    /// For structs, use the `put(inout [EntityType])` variant or `putAndReturnIDs()` and assign the returned
    /// IDs to each entity.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Throws: ObjectBoxError errors for database write errors.
    public func put<C: Collection>(_ entities: C, mode: PutMode = .put) throws
        where C.Element == EntityType {
        if entities.isEmpty {
            // Short-cut, we don't need a TX
            return
        }
        try store.obx_runInTransaction(writable: true, { swiftTx in
            let binding = EntityType.entityBinding
            let flatBuffer = FlatBufferBuilder.dequeue()
            defer { FlatBufferBuilder.return(flatBuffer) }

            let cursor = try Cursor<EntityType>(transaction: swiftTx)

            for entity in entities {
                let writtenId = try putOne(entity, binding: binding, flatBuffer: flatBuffer,
                                           mode: mode, cursor: cursor)
                try binding.postPut(fromEntity: entity, id: writtenId, store: store)
                binding.setEntityIdUnlessStruct(of: entity, to: writtenId)
            }
        })
    }

    /// :nodoc:
    public func put(_ entities: [EntityType], mode: PutMode = .put) throws {
        if entities.isEmpty {
            // Short-cut, we don't need a TX
            return
        }
        try store.obx_runInTransaction(writable: true, { swiftTx in
            let binding = EntityType.entityBinding
            let flatBuffer = FlatBufferBuilder.dequeue()
            defer { FlatBufferBuilder.return(flatBuffer) }

            let cursor = try Cursor<EntityType>(transaction: swiftTx)

            for entity in entities {
                let writtenId = try putOne(entity, binding: binding, flatBuffer: flatBuffer,
                                           mode: mode, cursor: cursor)
                try binding.postPut(fromEntity: entity, id: writtenId, store: store)
                binding.setEntityIdUnlessStruct(of: entity, to: writtenId)
            }
        })
    }

    /// Version of put([EntityType]) that is faster because it uses ContiguousArray.
    public func put(_ entities: ContiguousArray<EntityType>, mode: PutMode = .put) throws {
        if entities.isEmpty {
            // Short-cut, we don't need a TX
            return
        }
        try store.obx_runInTransaction(writable: true, { swiftTx in
            let binding = EntityType.entityBinding
            let flatBuffer = FlatBufferBuilder.dequeue()
            defer { FlatBufferBuilder.return(flatBuffer) }

            let cursor = try Cursor<EntityType>(transaction: swiftTx)

            for entity in entities {
                let writtenId = try putOne(entity, binding: binding, flatBuffer: flatBuffer,
                                           mode: mode, cursor: cursor)
                try binding.postPut(fromEntity: entity, id: writtenId, store: store)
                binding.setEntityIdUnlessStruct(of: entity, to: writtenId)
            }
        })
    }


    /// Puts the given structs in a box using a single transaction. Any entities that hadn't been persisted yet will be
    /// assigned an ID. The entities' ID properties will be set to match any newly-assigned IDs.
    ///
    /// - Parameter entities: Objects to persist and whose IDs will be updated if needed.
    /// - Parameter mode: Whether you want to put (insert or update), insert (fail if there is an existing object of
    ///                     the given ID) or update (fail if the object doesn't exist anymore).
    /// - Throws: ObjectBoxError errors for database write errors.
    public func put(_ entities: inout [EntityType], mode: PutMode = .put) throws {
        if entities.isEmpty {
            // Short-cut, we don't need a TX
            return
        }
        try store.obx_runInTransaction(writable: true, { swiftTx in
            let binding = EntityType.entityBinding
            let flatBuffer = FlatBufferBuilder.dequeue()
            defer { FlatBufferBuilder.return(flatBuffer) }

            let cursor = try Cursor<EntityType>(transaction: swiftTx)

            for entityIndex in 0 ..< entities.count {
                let newEntity = entities[entityIndex]
                let writtenId = try putOne(newEntity, binding: binding, flatBuffer: flatBuffer,
                                           mode: mode, cursor: cursor)
                try binding.postPut(fromEntity: newEntity, id: writtenId, store: store)
                binding.setStructEntityId(of: &entities[entityIndex], to: writtenId)
            }
        })
    }

    /// Puts the given entities in a box using a single transaction. Any entities that hadn't been persisted yet will be
    /// assigned an ID. For classes, the entity's ID property will be set to match any newly-assigned IDs.
    /// For structs, you will have to extract the IDs from the returned array of IDs and assign them to each entity.
    ///
    /// - Parameter entities: Objects to persist, passed as individual parameters, not as an array.
    /// - Returns: List of IDs of the entities were written to.
    /// - Throws: ObjectBoxError errors for database write errors.
    public func putAndReturnIDs(_ entities: EntityType..., mode: PutMode = .put) throws
        -> [EntityType.EntityBindingType.IdType] {
        return try putAndReturnIDs(entities, mode: mode)
    }

    /// Puts the given entities in a box using a single transaction. Any entities that hadn't been persisted yet will be
    /// assigned an ID. For classes, the entity's ID property will be set to match any newly-assigned IDs.
    /// For structs, use the `put(inout [EntityType])` variant or `putAndReturnIDs()` and assign the returned
    /// IDs to each entity.
    ///
    /// - Parameter entities: Objects to persist, passed as individual parameters, not as an array.
    /// - Throws: ObjectBoxError errors for database write errors.
    public func put(_ entities: EntityType..., mode: PutMode = .put) throws {
        try put(entities, mode: mode)
    }
}

// MARK: Reading Objects

extension Box {

    /// This function *must* be called inside a valid transaction. The transaction guarantees that the pointers returned
    /// by obx_box_get() stay valid until we've actually copied them.
    func getOne(_ id: Id, binding: EntityType.EntityBindingType,
                flatBuffer: inout FlatBufferReader) throws -> EntityType? {
        var ptr: UnsafeRawPointer?
        var size: Int = 0
        let err = obx_box_get(cBox, id, &ptr, &size)
        if err == OBX_NOT_FOUND { obx_last_error_clear(); return nil }
        try checkLastError(err)
        guard let safePtr = ptr else { return nil }
        flatBuffer.setCurrentlyReadTableBytes(UnsafeRawPointer(safePtr))
        return binding.createEntity(entityReader: flatBuffer, store: store)
    }

    /// Get the stored object for the given ID.
    ///
    /// - Parameter entityId: ID of the object.
    /// - Returns: The entity, if an object with `entityId` was found, `nil` otherwise.
    func get(id: Id) throws -> EntityType? {
        return try store.obx_runInTransaction(writable: false, { _ in
            let binding = EntityType.entityBinding
            var flatBuffer = FlatBufferReader()

            return try getOne(id.value, binding: binding, flatBuffer: &flatBuffer)
        })
    }

    /// Get the stored object for the given ID.
    ///
    /// - Parameter entityId: ID of the object.
    /// - Returns: The entity, if an object with `entityId` was found, `nil` otherwise.
    public func get<I: UntypedIdBase>(_ entityId: I) throws -> EntityType? {
        return try get(id: entityId.value)
    }

    /// Get the stored object for the given ID.
    ///
    /// - Parameter entityId: ID of the object.
    /// - Returns: The entity, if an object with `entityId` was found, `nil` otherwise.
    public func get(_ id: EntityId<EntityType>) throws -> EntityType? {
        return try get(id: id.value)
    }

    /// Gets the objects for the given IDs as an array.
    ///
    /// - Parameter ids: Object IDs to map to objects.
    /// - Returns: An array of the objects that were actually found; in the order of the given IDs.
    public func get<I: IdBase, C: Collection>(_ ids: C, maxCount: Int = 0)
    throws -> [EntityType] where C.Element == I {

        var result: [EntityType] = []
        result.reserveCapacity(maxCount > 0 ? maxCount : ids.count)

        let binding = EntityType.entityBinding
        var flatBuffer = FlatBufferReader()

        try store.runInReadOnlyTransaction {
            var count = 0
            // Prefer getting one by one: zero overhead calling into static library.
            // Consumes less memory compared to e.g. obx_box_get_many().
            for id in ids {
                if let entity = try getOne(id.value, binding: binding, flatBuffer: &flatBuffer) {
                    result.append(entity)
                    count += 1
                    if count == maxCount { break }
                }
            }
        }

        return result
    }

    /// Gets the objects for the given IDs as a dictionary.
    ///
    /// - Parameter ids: Object IDs to map to objects.
    /// - Returns: Dictionary of all `ids` and the corresponding objects.
    ///   Nothing is added to the dictionary for entities that can't be found.
    public func getAsDictionary<C: Collection>(_ ids: C) throws
        -> [EntityId<EntityType>: EntityType] where C.Element == EntityId<EntityType> {
            return try getAsDictionary(forIdBases: ids)
    }

    /// Gets the objects for the given IDs as a dictionary.
    ///
    /// - Parameter ids: Object IDs to map to objects.
    /// - Returns: Dictionary of all `ids` and the corresponding objects.
    ///   Nothing is added to the dictionary for entities that can't be found.
    public func getAsDictionary<I: UntypedIdBase, C: Collection>(_ ids: C) throws
        -> [I: EntityType] where C.Element == I {
            return try getAsDictionary(forIdBases: ids)
    }

    /// Gets the objects for the given IDs as a dictionary.
    ///
    /// - Parameter entityIds: Object IDs to map to objects.
    /// - Returns: Dictionary of all `entityIds` and the corresponding objects.
    ///   Nothing is added to the dictionary for entities that can't be found.
    private func getAsDictionary<I: IdBase, C: Collection>(forIdBases ids: C) throws
                    -> [I: EntityType] where C.Element == I {
        var result = [I: EntityType](minimumCapacity: ids.count)

        let binding = EntityType.entityBinding
        var flatBuffer = FlatBufferReader()
        try store.runInReadOnlyTransaction {

            // Prefer getting one by one: zero overhead calling into static library.
            // Consumes less memory compared to e.g. obx_box_get_many().
            for id in ids {
                if let entity = try getOne(id.value, binding: binding, flatBuffer: &flatBuffer) {
                    result[id] = entity
                }
            }
        }

        return result
    }

    /// Gets all objects from the box.
    /// - Throws: ObjectBoxError
    /// - Returns: All stored Objects in this Box.
    public func all() throws -> [EntityType] {
        if self.store.supportsLargeArrays {
            return try store.obx_runInTransaction(writable: false, { _ in
                guard let bytesArray = obx_box_get_all(cBox) else {
                    try checkLastError()  // should always throw
                    return [EntityType]()
                }
                defer {
                    obx_bytes_array_free(bytesArray)
                }
                return Array(try readAll(bytesArray.pointee))
            })
        } else {
            var result = [EntityType]()
            try visit { item in
                result.append(item)
                return true
            }
            return result
        }
    }

    /// Variant of all() that is faster due to using ContiguousArray.
    public func allContiguous() throws -> ContiguousArray<EntityType> {
        if self.store.supportsLargeArrays {
            return try store.runInReadOnlyTransaction {
                guard let bytesArray = obx_box_get_all(cBox) else {
                    try checkLastError() // should always throw
                    return ContiguousArray<EntityType>()
                }
                defer {
                    obx_bytes_array_free(bytesArray)
                }
                return try readAllContiguous(bytesArray.pointee)
            }
        } else {
            var result = ContiguousArray<EntityType>()
            try visit { item in
                result.append(item)
                return true
            }
            return result
        }
    }

    internal func readAllContiguous(_ bytesArray: OBX_bytes_array) throws -> ContiguousArray<EntityType> {
        var result = ContiguousArray<EntityType>()
        result.reserveCapacity(bytesArray.count)
        let binding = EntityType.entityBinding
        var flatBuffer = FlatBufferReader()

        // Crashes when I use the unsafeUninitializedCapacity initializer below instead of reserveCapacity above.
        // Seems it tries to deinit the uninitialized memory on assignment. Can't use init(repeating:) either as
        // empty user-defined entities may be expensive to create.
        try store.obx_runInTransaction(writable: false, { _ in
            for dataIndex in 0 ..< bytesArray.count {
                flatBuffer.setCurrentlyReadTableBytes(bytesArray.bytes[dataIndex].data)
                let entity = binding.createEntity(entityReader: flatBuffer, store: store)
                result.append(entity)
            }
        })
        return result
    }

    internal func readAll(_ bytesArray: OBX_bytes_array) throws -> [EntityType] {
        var result = [EntityType]()
        result.reserveCapacity(bytesArray.count)
        let binding = EntityType.entityBinding
        var flatBuffer = FlatBufferReader()

        // Crashes when I use the unsafeUninitializedCapacity initializer below instead of reserveCapacity above.
        // Seems it tries to deinit the uninitialized memory on assignment. Can't use init(repeating:) either as
        // empty user-defined entities may be expensive to create.
        try store.obx_runInTransaction(writable: false, { _ in
            for dataIndex in 0 ..< bytesArray.count {
                flatBuffer.setCurrentlyReadTableBytes(bytesArray.bytes[dataIndex].data)
                let entity = binding.createEntity(entityReader: flatBuffer, store: store)
                result.append(entity)
            }
        })
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
    public func visit(writable: Bool = false, visitor: (EntityType) throws -> Bool) throws {
        try store.obx_runInTransaction(writable: writable, { swiftTx in
            let cursor = try Cursor<EntityType>(transaction: swiftTx)
            try withoutActuallyEscaping(visitor) { callback in
                let context: InstanceVisitorBase = InstanceVisitor(type: EntityType.self, store: store,
                        visitor: callback)

                var currBytes = try cursor.first()
                while currBytes.data != nil {
                    if !context.visit(ptr: currBytes.data, size: currBytes.size) || context.userError != nil { break }
                    currBytes = try cursor.next()
                }

                if let err = context.userError {
                    throw err
                }
            }
        })
    }

    /// Iterate over all objects in this box, calling the given closure with each object.
    /// This lazily creates one object after the other and hands them to you, and if you do not hold on to the objects,
    /// will free their memory once done.
    /// - Parameter writable: By default the objects are traversed for read-only access.
    ///                       If you want to write, enable this flag to makes the enclosing transaction writable.
    /// - Parameter visitor: A closure that is called for each object in this box. Exceptions thrown by the closure are
    ///                      re-thrown.
    public func forEach(writable: Bool = false, _ visitor: (EntityType) throws -> Void) throws {
        try self.visit(writable: writable) { entity in
            try visitor(entity)
            return true
        }
    }

    /// Iterate over the objects in this box with the given IDs, calling the given closure with each object.
    /// This lazily creates one object after the other and hands them to you, and if you do not hold on to the objects,
    /// will free their memory once done.
    /// - Parameter writable: By default the objects are traversed for read-only access.
    ///                       If you want to write, enable this flag to makes the enclosing transaction writable.
    /// - Parameter visitor: A closure that is called for each object requested. If an object with the requested ID
    ///                      can't be found, you get a callback with a NIL entity. Exceptions thrown by the closure are
    ///                      re-thrown.
    public func `for`<C: Collection>(writable: Bool = false, _ ids: C, in visitor: (EntityType?) throws -> Void) throws
        where C.Element == EntityType.EntityBindingType.IdType {
        try self.visit(writable: writable, ids) { entity in
            try visitor(entity)
            return true
        }
    }

    /// Iterate over the objects in this box with the given IDs, calling the given closure with each object.
    /// This lazily creates one object after the other and hands them to you, and if you do not hold on to the objects,
    /// will free their memory once done.
    /// - Parameter writable: By default the objects are traversed for read-only access.
    ///                       If you want to write, enable this flag to makes the enclosing transaction writable.
    /// - Parameter visitor: A closure that is called for each object requested. If an object with the requested ID
    ///                      can't be found, you get a callback with a NIL entity. Exceptions thrown by the closure are
    ///                      re-thrown.
    public func visit<C: Collection>(writable: Bool = false, _ ids: C, in visitor: (EntityType?) throws -> Bool) throws
    where C.Element == EntityType.EntityBindingType.IdType {
        try store.obx_runInTransaction(writable: writable, { swiftTx in
            let cursor = try Cursor<EntityType>(transaction: swiftTx)
            try withoutActuallyEscaping(visitor) { callback in
                let context = InstanceVisitor(type: EntityType.self, store: store,
                                                                   visitor: callback)

                for currId in ids {
                    let currBytes = try cursor.get(currId.value)
                    if !context.visit(ptr: currBytes.data, size: currBytes.size) || context.userError != nil { break }
                }

                if let err = context.userError {
                    throw err
                }
            }
        })
    }
}

// MARK: Removing Objects

extension Box {

    /// Removes (deletes) the Object by its ID.
    ///
    /// - Parameter entityId: ID of the object to delete.
    /// - Returns: false if `entityId` is 0, true if the object was successfully deleted.
    /// - Throws: ObjectBoxError errors for database write errors, `.notFound` if there is no object of that ID.
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
    /// - Throws: ObjectBoxError errors for database write errors, `.notFound` if there is no object of that ID.
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
    /// - Throws: ObjectBoxError errors for database write errors, `.notFound` if there is no object of that ID anymore.
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
    /// - Throws: ObjectBoxError errors for database write errors. Will *not* throw if an object can't be found in the
    ///           database. Use `contains()` or check the returned number of deleted entities if you need to fail.
    @discardableResult
    public func remove<C: Collection>(_ entities: C) throws -> UInt64
        where C.Element == EntityType {
            var result: UInt64 = 0

            try store.obx_runInTransaction(writable: true, { swiftTx in
                let cursor = try Cursor<EntityType>(transaction: swiftTx)

                for currEntity in entities {
                    if try cursor.remove(currEntity) {
                        result += 1
                    }
                }
            })

            return result
    }

    /// :nodoc:
    @discardableResult
    public func remove(_ entities: [EntityType]) throws -> UInt64 {
        var result: UInt64 = 0

        try store.obx_runInTransaction(writable: true, { swiftTx in
            let cursor = try Cursor<EntityType>(transaction: swiftTx)

            for currEntity in entities {
                if try cursor.remove(currEntity) {
                    result += 1
                }
            }
        })

        return result
    }

    /// Version of remove() that is faster because it uses ContiguousArray.
    @discardableResult
    public func remove(_ entities: ContiguousArray<EntityType>) throws -> UInt64 {
        var result: UInt64 = 0

        try store.obx_runInTransaction(writable: true, { swiftTx in
            let cursor = try Cursor<EntityType>(transaction: swiftTx)

            for currEntity in entities {
                if try cursor.remove(currEntity) {
                    result += 1
                }
            }
        })

        return result
    }

    /// Removes (deletes) the given objects (passed as individual parameters) in a single transaction.
    ///
    /// It is valid to pass objects here that haven't been persisted yet.
    ///
    /// - Parameter entities: Objects to delete.
    /// - Returns: Count of objects that were removed.
    /// - Throws: ObjectBoxError errors for database write errors. Will *not* throw if an object can't be found in the
    ///           database. Use `contains()` or check the returned number of deleted entities if you need to fail.
    @discardableResult
    public func remove(_ entities: EntityType...) throws -> UInt64 {
        return try self.remove(entities)
    }

    /// :nodoc:
    @discardableResult
    public func remove(_ entityIDs: [Id]) throws -> UInt64 {
        var result: UInt64 = 0
        try store.obx_runInTransaction(writable: true, { swiftTx in
            let cursor = try Cursor<EntityType>(transaction: swiftTx)
            for currId in entityIDs {
                if try cursor.remove(currId.value) {
                    result += 1
                }
            }
        })
        return result
    }

    /// Removes (deletes) the objects with the given IDs in a single transaction.
    ///
    /// It is valid to pass IDs of objects here that haven't been persisted yet (i.e. any 0 ID  is skipped). If an
    /// entity is passed whose ID doesn't exist anymore, only the entities up to that entity will be removed.
    ///
    /// - Parameter ids: IDs of objects to delete.
    /// - Returns: Count of objects that were removed.
    /// - Throws: ObjectBoxError errors for database write errors. Will *not* throw if an object can't be found in the
    ///           database. Use `contains()` or check the returned number of deleted entities if you need to fail.
    @discardableResult
    public func remove<I: UntypedIdBase, C: Collection>(_ ids: C) throws -> UInt64
        where C.Element == I {
            return try remove(collection: ids)
    }

    /// :nodoc:
    @discardableResult
    internal func remove<I: UntypedIdBase, C: Collection>(collection ids: C) throws -> UInt64
        where C.Element == I {
            var result: UInt64 = 0

            try store.obx_runInTransaction(writable: true, { swiftTx in
                let cursor = try Cursor<EntityType>(transaction: swiftTx)
                for currId in ids {
                    if try cursor.remove(currId.value) {
                        result += 1
                    }
                }
            })

            return result
    }

    /// Removes (deletes) the objects with the given IDs (passed as individual parameters) in a single
    /// transaction.
    ///
    /// It is valid to pass IDs of objects here that haven't been persisted yet (i.e. any 0 ID  is skipped). If an
    /// entity is passed whose ID doesn't exist anymore, only the entities up to that entity will be removed.
    ///
    /// - Parameter entities: Objects to delete.
    /// - Returns: Count of objects that were removed.
    /// - Throws: ObjectBoxError errors for database write errors. Will *not* throw if an object can't be found in the
    ///           database. Use `contains()` or check the returned number of deleted entities if you need to fail.
    @discardableResult
    public func remove<I: UntypedIdBase>(_ ids: I...) throws -> UInt64 {
        return try remove(ids)
    }

    /// :nodoc:
    @discardableResult
    public func remove(_ ids: Id...) throws -> UInt64 {
        return try remove(ids)
    }

    /// :nodoc:
    @discardableResult
    public func remove(_ entityIDs: [EntityId<EntityType>]) throws -> UInt64 {
        var result: UInt64 = 0
        try store.obx_runInTransaction(writable: true, { swiftTx in
            let cursor = try Cursor<EntityType>(transaction: swiftTx)
            for currId in entityIDs {
                if try cursor.remove(currId.value) {
                    result += 1
                }
            }
        })
        return result
    }

    /// Removes (deletes) the objects with the given IDs in a single transaction.
    ///
    /// It is valid to pass IDs of objects here that haven't been persisted yet (i.e. any 0 ID  is skipped). If an
    /// entity is passed whose ID doesn't exist anymore, only the entities up to that entity will be removed.
    ///
    /// - Parameter ids: IDs of objects to delete.
    /// - Returns: Count of objects that were removed.
    /// - Throws: ObjectBoxError errors for database write errors. Will *not* throw if an object can't be found in the
    ///           database. Use `contains()` or check the returned number of deleted entities if you need to fail.
    @discardableResult
    public func remove<C: Collection>(_ entityIDs: C) throws -> UInt64
        where C.Element == EntityId<EntityType> {
            return try remove(collection: entityIDs)
    }

    /// :nodoc:
    @discardableResult
    internal func remove<C: Collection>(collection entityIDs: C) throws -> UInt64
        where C.Element == EntityId<EntityType> {
        var result: UInt64 = 0

        try store.obx_runInTransaction(writable: true, { swiftTx in
            let cursor = try Cursor<EntityType>(transaction: swiftTx)
            for currId in entityIDs {
                if try cursor.remove(currId.value) {
                    result += 1
                }
            }
        })

        return result
    }

    /// Removes (deletes) the objects with the given IDs (passed as individual objects) in a single transaction.
    ///
    /// It is valid to pass IDs of objects here that haven't been persisted yet (i.e. any 0 ID  is skipped). If an
    /// entity is passed whose ID doesn't exist anymore, only the entities up to that entity will be removed.
    ///
    /// - Parameter entities: Objects to delete.
    /// - Returns: Count of objects that were removed.
    /// - Throws: ObjectBoxError errors for database write errors. Will *not* throw if an object can't be found in the
    ///           database. Use `contains()` or check the returned number of deleted entities if you need to fail.
    @discardableResult
    public func remove(_ ids: EntityId<EntityType>...) throws -> UInt64 {
        return try remove(ids)
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

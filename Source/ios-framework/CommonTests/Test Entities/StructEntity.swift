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
import ObjectBox

// swiftlint:disable identifier_name line_length

struct StructEntity {
    var id: EntityId<StructEntity>
    var message: String
    var date: Date
}

extension StructEntity: Entity {}

extension StructEntity: __EntityRelatable {
    internal typealias EntityType = StructEntity
    
    internal var _id: EntityId<StructEntity> {
        return self.id
    }
}

extension StructEntity: EntityInspectable {
    internal typealias EntityBindingType = StructEntityCursor
    
    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = EntityInfo(name: "StructEntity", id: 3)

    static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: StructEntity.self, id: 3, uid: 1002)
        try entityBuilder.addProperty(name: "id", type: EntityId<StructEntity>.entityPropertyType, flags: [.id], id: 1, uid: 12)
        try entityBuilder.addProperty(name: "message", type: String.entityPropertyType, id: 2, uid: 13)
        try entityBuilder.addProperty(name: "date", type: Date.entityPropertyType, id: 3, uid: 14)
        try entityBuilder.lastProperty(id: 3, uid: 14)
    }
}

extension StructEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { StructEntity.id == myId }
    internal static var id: Property<StructEntity, EntityId<StructEntity>, Void> { return Property<StructEntity, EntityId<StructEntity>, Void>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { StructEntity.message.startsWith("X") }
    internal static var message: Property<StructEntity, String, Void> { return Property<StructEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { StructEntity.date > 1234 }
    internal static var date: Property<StructEntity, Date, Void> { return Property<StructEntity, Date, Void>(propertyId: 3, isPrimaryKey: false) }
}

extension Property where E == StructEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }
    
    static var id: Property<StructEntity, EntityId<StructEntity>, Void> { return Property<StructEntity, EntityId<StructEntity>, Void>(propertyId: 1, isPrimaryKey: true) }
    
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .message.startsWith("X") }
    
    static var message: Property<StructEntity, String, Void> { return Property<StructEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }
    
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .date > 1234 }
    
    static var date: Property<StructEntity, Date, Void> { return Property<StructEntity, Date, Void>(propertyId: 3, isPrimaryKey: false) }
    
    
}


/// Generated service type to handle persisting and reading entity data. Exposed through `StructEntity.entitySchemaId`.
internal class StructEntityCursor: EntityBinding {
    internal typealias EntityType = StructEntity
    internal typealias IdType = EntityId<StructEntity>

    internal required init() {}

    public func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: Id) {
        // Use the struct variants of the put methods on entities of struct StructEntity.
    }
    
    internal func setStructEntityId(of entity: inout EntityType, to entityId: Id) {
        entity.id = EntityId(entityId)
    }
    
    internal func entityId(of entity: EntityType) -> Id {
        return entity.id.value
    }
    
    internal func collect(fromEntity entity: EntityType, id: Id, propertyCollector: FlatBufferBuilder, store: Store) {
        
        var offsets: [(offset: OBXDataOffset, index: UInt16)] = []
        offsets.append((propertyCollector.prepare(string: entity.message), 2 + 2 * 2))
        
        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.date, at: 2 + 2 * 3)

        for value in offsets {
            propertyCollector.collect(dataOffset: value.offset, at: value.index)
        }
    }
    
    internal func createEntity(entityReader: FlatBufferReader, store: Store) -> EntityType {
        let entityId: EntityId<StructEntity> = entityReader.read(at: 2 + 2 * 1)
        let entity = StructEntity(
            id: entityId,
            message: entityReader.read(at: 2 + 2 * 2),
            date: entityReader.read(at: 2 + 2 * 3)
        )
        
        return entity
    }
}

extension Box where E == StructEntity {
    
    /// Puts a StructEntity in the box (aka persisting it) without adjusting its ID.
    ///
    /// - Parameter entity: Object to persist.
    /// - Returns: The stored object. If `entity`'s id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(struct entity: StructEntity, mode: PutMode = .put) throws -> StructEntity {
        let entityId: EntityId<StructEntity> = try self.put(entity, mode: mode)
        
        return StructEntity(
            id: entityId,
            message: entity.message,
            date: entity.date
        )
    }
    
    /// Puts the StructEntitys in the box (aka persisting it) without adjusting their IDs.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Returns: The stored objects. If any entity's id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(structs entities: [StructEntity], mode: PutMode = .put) throws -> [StructEntity] {
        let entityIds: [EntityId<StructEntity>] = try self.putAndReturnIDs(entities, mode: mode)
        var newEntities = [StructEntity]()
        
        for i in 0 ..< min(entities.count, entityIds.count) {
            let entity = entities[i]
            let entityId = entityIds[i]
            
            newEntities.append(StructEntity(
                id: entityId,
                message: entity.message,
                date: entity.date
            ))
        }
        
        return newEntities
    }
}

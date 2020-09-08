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

@testable import ObjectBox

// swiftlint:disable identifier_name line_length
class PureSwiftEntity: Entity, EntityInspectable, __EntityRelatable {
    public typealias EntityBindingType = PureSwiftEntityBinding
    
    static var entityBinding = EntityBindingType()
    
    var id: EntityId<PureSwiftEntity>
    var _id: EntityId<PureSwiftEntity> { return id }
    var integerValue: Int32
    var maybeLongValue: Int64?

    static var id: Property<PureSwiftEntity, EntityId<PureSwiftEntity>, Void> { return Property(propertyId: 1, isPrimaryKey: true) }
    static var integer: Property<PureSwiftEntity, Int32, Void> { return Property(propertyId: 2, isPrimaryKey: false) }
    static var maybeLong: Property<PureSwiftEntity, Int64?, Void> { return Property(propertyId: 3, isPrimaryKey: false) }

    required init() {
        self.id = 0
        self.integerValue = 1234
        self.maybeLongValue = nil
    }

    convenience init(id: EntityId<PureSwiftEntity> = 0, integerValue: Int32 = 123456, maybeLongValue: Int64? = nil) {
        self.init()
        self.id = id
        self.integerValue = integerValue
        self.maybeLongValue = maybeLongValue
    }

    static var entityInfo = EntityInfo(name: "PureSwiftEntity", id: 3)

    static func buildEntity(modelBuilder: ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: PureSwiftEntity.self, id: 3,
                                                                                           uid: 1003)
        try entityBuilder.addProperty(name: "id", type: .long, flags: [.id], id: 1, uid: 1)
        try entityBuilder.addProperty(name: "integerValue", type: Int32.entityPropertyType, id: 2, uid: 2)
        try entityBuilder.addProperty(name: "maybeLongValue", type: Int64?.entityPropertyType, id: 3, uid: 3)
        try entityBuilder.lastProperty(id: 3, uid: 3)
    }
}

class PureSwiftEntityBinding: EntityBinding {
    typealias EntityType = PureSwiftEntity
    typealias IdType = EntityId<PureSwiftEntity>

    required init() {}

    public func generatorBindingVersion() -> Int { 1 }

    func collect(fromEntity entity: PureSwiftEntity, id: Id, propertyCollector: FlatBufferBuilder, store: Store) {
        propertyCollector.collect(id, at: 2 + 2*1)
        
        propertyCollector.collect(entity.integerValue, at: 2 + 2*2)
        propertyCollector.collect(entity.maybeLongValue, at: 2 + 2*3)
    }
    
    func createEntity(entityReader: FlatBufferReader, store: Store) -> PureSwiftEntity {
        let entity = PureSwiftEntity()
        entity.id = entityReader.read(at: 2 + 2*1)
        entity.integerValue = entityReader.read(at: 2 + 2*2)
        entity.maybeLongValue = entityReader.read(at: 2 + 2*3)
        return entity
    }
    
    func setEntityIdUnlessStruct(of entity: PureSwiftEntity, to entityId: Id) {
        entity.id = EntityId(entityId)
    }
    
    func entityId(of entity: PureSwiftEntity) -> Id {
        return entity.id.value
    }
}

// swiftlint:enable identifier_name force_cast line_length

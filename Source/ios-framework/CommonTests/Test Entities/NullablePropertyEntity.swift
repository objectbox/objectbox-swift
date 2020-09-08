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
class NullablePropertyEntity: Entity, EntityInspectable, __EntityRelatable {
    typealias EntityBindingType = NullablePropertyEntityBinding
    
    static var entityBinding = EntityBindingType()
    
    var id: EntityId<NullablePropertyEntity>
    var _id: EntityId<NullablePropertyEntity> { return id }
    var maybeBool: Bool?
    var maybeInt: Int?
    var maybeInt64: Int64?
    var maybeInt32: Int32?
    var maybeInt16: Int16?
    var maybeInt8: Int8?
    var maybeFloat: Float?
    var maybeDouble: Double?
    var maybeDate: Date?
    var maybeString: String?
    var maybeByteVector: Data?

    var bool: Bool
    var int: Int
    var int64: Int64
    var int32: Int32
    var int16: Int16
    var int8: Int8
    var float: Float
    var double: Double
    var date: Date
    var string: String
    var byteVector: Data

    static var id: Property<NullablePropertyEntity, EntityId<NullablePropertyEntity>, Void> { return Property(propertyId: 1, isPrimaryKey: true) }

    static var maybeBool: Property<NullablePropertyEntity, Bool?, Void> { return Property(propertyId: 2) }
    static var maybeInt: Property<NullablePropertyEntity, Int?, Void> { return Property(propertyId: 3) }
    static var maybeInt64: Property<NullablePropertyEntity, Int64?, Void> { return Property(propertyId: 4) }
    static var maybeInt32: Property<NullablePropertyEntity, Int32?, Void> { return Property(propertyId: 5) }
    static var maybeInt16: Property<NullablePropertyEntity, Int16?, Void> { return Property(propertyId: 6) }
    static var maybeInt8: Property<NullablePropertyEntity, Int8?, Void> { return Property(propertyId: 7) }
    static var maybeFloat: Property<NullablePropertyEntity, Float?, Void> { return Property(propertyId: 8) }
    static var maybeDouble: Property<NullablePropertyEntity, Double?, Void> { return Property(propertyId: 9) }
    static var maybeDate: Property<NullablePropertyEntity, Date?, Void> { return Property(propertyId: 10) }
    static var maybeString: Property<NullablePropertyEntity, String?, Void> { return Property(propertyId: 11) }
    static var maybeByteVector: Property<NullablePropertyEntity, Data?, Void> { return Property(propertyId: 12) }

    static var bool: Property<NullablePropertyEntity, Bool, Void> { return Property(propertyId: 13) }
    static var int: Property<NullablePropertyEntity, Int, Void> { return Property(propertyId: 14) }
    static var int64: Property<NullablePropertyEntity, Int64, Void> { return Property(propertyId: 15) }
    static var int32: Property<NullablePropertyEntity, Int32, Void> { return Property(propertyId: 16) }
    static var int16: Property<NullablePropertyEntity, Int16, Void> { return Property(propertyId: 17) }
    static var int8: Property<NullablePropertyEntity, Int8, Void> { return Property(propertyId: 18) }
    static var float: Property<NullablePropertyEntity, Float, Void> { return Property(propertyId: 19) }
    static var double: Property<NullablePropertyEntity, Double, Void> { return Property(propertyId: 20) }
    static var date: Property<NullablePropertyEntity, Date, Void> { return Property(propertyId: 21) }
    static var string: Property<NullablePropertyEntity, String, Void> { return Property(propertyId: 22) }
    static var byteVector: Property<NullablePropertyEntity, Data, Void> { return Property(propertyId: 23) }

    required init() {
        self.id = 0

        self.maybeBool = nil
        self.maybeInt = nil
        self.maybeInt64 = nil
        self.maybeInt32 = nil
        self.maybeInt16 = nil
        self.maybeInt8 = nil
        self.maybeFloat = nil
        self.maybeDouble = nil
        self.maybeDate = nil
        self.maybeString = nil
        self.maybeByteVector = nil

        self.bool = false
        self.int = 0
        self.int64 = 0
        self.int32 = 0
        self.int16 = 0
        self.int8 = 0
        self.float = 0.0
        self.double = 0.0
        self.date = Date()
        self.string = ""
        self.byteVector = Data()
    }

    convenience init(id: EntityId<NullablePropertyEntity> = 0,

                     maybeBool: Bool? = nil,
                     maybeInt: Int? = nil, maybeInt8: Int8? = nil, maybeInt16: Int16? = nil, maybeInt32: Int32? = nil, maybeInt64: Int64? = nil,
                     maybeFloat: Float? = nil, maybeDouble: Double? = nil,
                     maybeDate: Date? = nil,
                     maybeString: String? = nil, maybeByteVector: Data? = nil,

                     bool: Bool = false,
                     int: Int = 0, int8: Int8 = 0, int16: Int16 = 0, int32: Int32 = 0, int64: Int64 = 0,
                     float: Float = 0.0, double: Double = 0.0,
                     date: Date = Date(),
                     string: String = "", byteVector: Data = Data()) {
        self.init()
        self.id = id

        self.maybeBool = maybeBool
        self.maybeInt = maybeInt
        self.maybeInt64 = maybeInt64
        self.maybeInt32 = maybeInt32
        self.maybeInt16 = maybeInt16
        self.maybeInt8 = maybeInt8
        self.maybeFloat = maybeFloat
        self.maybeDouble = maybeDouble
        self.maybeDate = maybeDate
        self.maybeString = maybeString
        self.maybeByteVector = maybeByteVector

        self.bool = bool
        self.int = int
        self.int64 = int64
        self.int32 = int32
        self.int16 = int16
        self.int8 = int8
        self.float = float
        self.double = double
        self.date = date
        self.string = string
        self.byteVector = byteVector
    }

    static var entityInfo = EntityInfo(name: "NullablePropertyEntity", id: 1)

    static func buildEntity(modelBuilder: ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: NullablePropertyEntity.self, id: 1, uid: 1)
        try entityBuilder.addProperty(name: "id", type: EntityId<NullablePropertyEntity>.entityPropertyType, flags: [.id], id: 1, uid: 1002)

        try entityBuilder.addProperty(name: "maybeBool", type: Bool?.entityPropertyType, id: 2, uid: 2)
        try entityBuilder.addProperty(name: "maybeInt", type: Int?.entityPropertyType, id: 3, uid: 3)
        try entityBuilder.addProperty(name: "maybeInt64", type: Int64?.entityPropertyType, id: 4, uid: 4)
        try entityBuilder.addProperty(name: "maybeInt32", type: Int32?.entityPropertyType, id: 5, uid: 5)
        try entityBuilder.addProperty(name: "maybeInt16", type: Int16?.entityPropertyType, id: 6, uid: 6)
        try entityBuilder.addProperty(name: "maybeInt8", type: Int8?.entityPropertyType, id: 7, uid: 7)
        try entityBuilder.addProperty(name: "maybeFloat", type: Float?.entityPropertyType, id: 8, uid: 8)
        try entityBuilder.addProperty(name: "maybeDouble", type: Double?.entityPropertyType, id: 9, uid: 9)
        try entityBuilder.addProperty(name: "maybeDate", type: Date?.entityPropertyType, id: 10, uid: 10)
        try entityBuilder.addProperty(name: "maybeString", type: String?.entityPropertyType, id: 11, uid: 11)
        try entityBuilder.addProperty(name: "maybeByteVector", type: Data?.entityPropertyType, id: 12, uid: 12)

        try entityBuilder.addProperty(name: "bool", type: Bool.entityPropertyType, id: 13, uid: 13)
        try entityBuilder.addProperty(name: "int", type: Int.entityPropertyType, id: 14, uid: 14)
        try entityBuilder.addProperty(name: "int64", type: Int64.entityPropertyType, id: 15, uid: 15)
        try entityBuilder.addProperty(name: "int32", type: Int32.entityPropertyType, id: 16, uid: 16)
        try entityBuilder.addProperty(name: "int16", type: Int16.entityPropertyType, id: 17, uid: 17)
        try entityBuilder.addProperty(name: "int8", type: Int8.entityPropertyType, id: 18, uid: 18)
        try entityBuilder.addProperty(name: "float", type: Float.entityPropertyType, id: 19, uid: 19)
        try entityBuilder.addProperty(name: "double", type: Double.entityPropertyType, id: 20, uid: 20)
        try entityBuilder.addProperty(name: "date", type: Date.entityPropertyType, id: 21, uid: 21)
        try entityBuilder.addProperty(name: "string", type: String.entityPropertyType, id: 22, uid: 22)
        try entityBuilder.addProperty(name: "byteVector", type: Data.entityPropertyType, id: 23, uid: 23)
        try entityBuilder.lastProperty(id: 23, uid: 23)
        
        modelBuilder.lastEntity(id: 1, uid: 1)
        modelBuilder.lastIndex(id: 0, uid: 0)
    }
}

class NullablePropertyEntityBinding: EntityBinding {
    typealias EntityType = NullablePropertyEntity
    typealias IdType = EntityId<NullablePropertyEntity>

    required init() {}

    func generatorBindingVersion() -> Int { 1 }

    func collect(fromEntity entity: NullablePropertyEntity, id: Id, propertyCollector: FlatBufferBuilder, store: Store) {
        let maybeStringOffset = propertyCollector.prepare(string: entity.maybeString)
        let maybeByteVectorOffset = propertyCollector.prepare(bytes: entity.maybeByteVector)
        let stringOffset = propertyCollector.prepare(string: entity.string)
        let byteVectorOffset = propertyCollector.prepare(bytes: entity.byteVector)
        
        propertyCollector.collect(id, at: 2 + 2*1)
        
        propertyCollector.collect(entity.maybeBool, at: 2 + 2*2)
        propertyCollector.collect(entity.maybeInt, at: 2 + 2*3)
        propertyCollector.collect(entity.maybeInt64, at: 2 + 2*4)
        propertyCollector.collect(entity.maybeInt32, at: 2 + 2*5)
        propertyCollector.collect(entity.maybeInt16, at: 2 + 2*6)
        propertyCollector.collect(entity.maybeInt8, at: 2 + 2*7)
        propertyCollector.collect(entity.maybeFloat, at: 2 + 2*8)
        propertyCollector.collect(entity.maybeDouble, at: 2 + 2*9)
        propertyCollector.collect(entity.maybeDate, at: 2 + 2*10)
        
        propertyCollector.collect(entity.bool, at: 2 + 2*13)
        propertyCollector.collect(entity.int, at: 2 + 2*14)
        propertyCollector.collect(entity.int64, at: 2 + 2*15)
        propertyCollector.collect(entity.int32, at: 2 + 2*16)
        propertyCollector.collect(entity.int16, at: 2 + 2*17)
        propertyCollector.collect(entity.int8, at: 2 + 2*18)
        propertyCollector.collect(entity.float, at: 2 + 2*19)
        propertyCollector.collect(entity.double, at: 2 + 2*20)
        propertyCollector.collect(entity.date, at: 2 + 2*21)
        
        propertyCollector.collect(dataOffset: maybeStringOffset, at: 2 + 2*11)
        propertyCollector.collect(dataOffset: maybeByteVectorOffset, at: 2 + 2*12)
        propertyCollector.collect(dataOffset: stringOffset, at: 2 + 2*22)
        propertyCollector.collect(dataOffset: byteVectorOffset, at: 2 + 2*23)
    }
    
    func createEntity(entityReader: FlatBufferReader, store: Store) -> NullablePropertyEntity {
        let entity = NullablePropertyEntity()
        
        entity.id = entityReader.read(at: 2 + 2*1)
        
        entity.maybeBool = entityReader.read(at: 2 + 2*2)
        entity.maybeInt = entityReader.read(at: 2 + 2*3)
        entity.maybeInt64 = entityReader.read(at: 2 + 2*4)
        entity.maybeInt32 = entityReader.read(at: 2 + 2*5)
        entity.maybeInt16 = entityReader.read(at: 2 + 2*6)
        entity.maybeInt8 = entityReader.read(at: 2 + 2*7)
        entity.maybeFloat = entityReader.read(at: 2 + 2*8)
        entity.maybeDouble = entityReader.read(at: 2 + 2*9)
        entity.maybeDate = entityReader.read(at: 2 + 2*10)
        entity.maybeString = entityReader.read(at: 2 + 2*11)
        entity.maybeByteVector = entityReader.read(at: 2 + 2*12)
        
        entity.bool = entityReader.read(at: 2 + 2*13)
        entity.int = entityReader.read(at: 2 + 2*14)
        entity.int64 = entityReader.read(at: 2 + 2*15)
        entity.int32 = entityReader.read(at: 2 + 2*16)
        entity.int16 = entityReader.read(at: 2 + 2*17)
        entity.int8 = entityReader.read(at: 2 + 2*18)
        entity.float = entityReader.read(at: 2 + 2*19)
        entity.double = entityReader.read(at: 2 + 2*20)
        entity.date = entityReader.read(at: 2 + 2*21)
        entity.string = entityReader.read(at: 2 + 2*22)
        entity.byteVector = entityReader.read(at: 2 + 2*23)
        
        return entity
    }
    
    func setEntityIdUnlessStruct(of entity: NullablePropertyEntity, to entityId: Id) {
        entity.id = EntityId(entityId)
    }
    
    func entityId(of entity: NullablePropertyEntity) -> Id {
        return entity.id.value
    }
}

// swiftlint:enable identifier_name force_cast line_length

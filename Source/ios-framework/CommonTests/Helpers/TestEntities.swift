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

// swiftlint:disable identifier_name

enum AllTypesOffset: UInt16 {
    case ID = 4
    case bool = 6
    case long = 8
    case integer = 10
    case unsignedInteger = 12
    case double = 14
    case date = 16
    case string = 18
}


public class TestPerson: CustomDebugStringConvertible {
    var id: EntityId<TestPerson> = 0
    var name: String?
    var age: Int
    
    static var irrelevant: TestPerson {
        return TestPerson(name: "Irrelevant", age: 123)
    }
    
    init(name: String? = nil, age: Int = 0) {
        self.name = name
        self.age = age
    }
    
    public var debugDescription: String {
        return "TestPerson(\(id.value): \(name ?? "") @\(age))"
    }
}

extension TestPerson: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: TestPerson, rhs: TestPerson) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.age == rhs.age
    }
}

public class AllTypesEntity {
    public var id: EntityId<AllTypesEntity> = 0
    public var boolean: Bool = false
    public var aLong: Int = 0
    public var integer: Int32 = 0
    public var unsigned: UInt32 = 0
    public var aDouble: Double = 0
    public var date: Date?
    public var string: String?
    
    static func create(integer: Int32, double: Double, string: String) -> AllTypesEntity {
        let newEntity = AllTypesEntity()
        
        newEntity.integer = integer
        newEntity.aDouble = double
        newEntity.string = string
        
        return newEntity
    }
    
    static func create(long: Int) -> AllTypesEntity {
        let newEntity = AllTypesEntity()
        
        newEntity.aLong = long
        
        return newEntity
    }
    
    static func create(integer: Int32) -> AllTypesEntity {
        let newEntity = AllTypesEntity()
        newEntity.integer = integer
        return newEntity
    }
    
    static func create(unsigned: UInt32) -> AllTypesEntity {
        let newEntity = AllTypesEntity()
        newEntity.unsigned = unsigned
        return newEntity
    }

    static func create(double: Double) -> AllTypesEntity {
        let newEntity = AllTypesEntity()
        newEntity.aDouble = double
        return newEntity
    }
    
    static func create(date: Date) -> AllTypesEntity {
        let newEntity = AllTypesEntity()
        newEntity.date = date
        return newEntity
    }
    
    static func create(string: String?) -> AllTypesEntity {
        let newEntity = AllTypesEntity()
        newEntity.string = string
        return newEntity
    }
    
    static func create(boolean: Bool) -> AllTypesEntity {
        let newEntity = AllTypesEntity()
        newEntity.boolean = boolean
        return newEntity
    }
}

/// Create the entity model, which is to be passed to ObjectStore.create(...)
// swiftlint:disable identifier_name force_try
public func createTestModel() -> OpaquePointer {
    let modelBuilder = try! ModelBuilder()
    
    let allTypesEntityBuilder = try! modelBuilder.entityBuilder(for: AllTypesEntity.self, id: 1, uid: 1000)
    try! allTypesEntityBuilder.addProperty(name: "id", type: .long, flags: .id, id: 1, uid: 1)
    try! allTypesEntityBuilder.addProperty(name: "boolean", type: .bool, id: 2, uid: 2)
    try! allTypesEntityBuilder.addProperty(name: "aLong", type: .long, id: 3, uid: 3)
    try! allTypesEntityBuilder.addProperty(name: "integer", type: .int, id: 4, uid: 4)
    try! allTypesEntityBuilder.addProperty(name: "unsigned", type: .int, flags: .unsigned, id: 5, uid: 5)
    try! allTypesEntityBuilder.addProperty(name: "aDouble", type: .double, id: 6, uid: 6)
    try! allTypesEntityBuilder.addProperty(name: "date", type: .date, id: 7, uid: 7)
    try! allTypesEntityBuilder.addProperty(name: "string", type: .string, id: 8, uid: 8)
    try! allTypesEntityBuilder.lastProperty(id: 8, uid: 8)

    let personEntityBuilder = try! modelBuilder.entityBuilder(for: TestPerson.self, id: 2, uid: 1001)
    try! personEntityBuilder.addProperty(name: "id", type: .long, flags: .id, id: 1, uid: 9)
    try! personEntityBuilder.addProperty(name: "age", type: .long, id: 2, uid: 10)
    try! personEntityBuilder.addProperty(name: "name", type: .string, id: 3, uid: 11)
    try! personEntityBuilder.lastProperty(id: 3, uid: 11)

    let structEntityBuilder = try! modelBuilder.entityBuilder(for: StructEntity.self, id: 3, uid: 1002)
    try! structEntityBuilder.addProperty(name: "id", type: .long, flags: .id, id: 1, uid: 12)
    try! structEntityBuilder.addProperty(name: "message", type: .string, id: 2, uid: 13)
    try! structEntityBuilder.addProperty(name: "date", type: .date, id: 3, uid: 14)
    try! structEntityBuilder.lastProperty(id: 3, uid: 14)
    
    modelBuilder.lastEntity(id: 3, uid: 1002)
    modelBuilder.lastIndex(id: 0, uid: 0)

    return modelBuilder.finish()
}

// MARK: Generated code.

extension TestPerson: Entity, EntityInspectable, __EntityRelatable {
    public typealias EntityBindingType = TestPersonCursor
    
    public static var entityBinding = EntityBindingType()
    
    public static var entityInfo = EntityInfo(name: "TestPerson", id: 2)
    
    public var _id: EntityId<TestPerson> { return self.id }

    public static var age: Property<TestPerson, Int, Void> {
        return Property(propertyId: 2, isPrimaryKey: false)
    }

    public static var name: Property<TestPerson, String, Void> {
        return Property(propertyId: 3, isPrimaryKey: false)
    }
}

extension AllTypesEntity: Entity, EntityInspectable, __EntityRelatable {
    public typealias EntityType = AllTypesEntity
    
    public typealias EntityBindingType = AllTypesEntityCursor
    
    public static var entityBinding = EntityBindingType()
    
    public static var entityInfo = EntityInfo(name: "AllTypesEntity", id: 1)

    public var _id: EntityId<AllTypesEntity> { return self.id }

    public static var boolean: Property<AllTypesEntity, Bool, Void> {
        return Property(propertyId: 2, isPrimaryKey: false)
    }
    
    public static var long: Property<AllTypesEntity, Int, Void> {
        return Property(propertyId: 3, isPrimaryKey: false)
    }

    public static var integer: Property<AllTypesEntity, Int32, Void> {
        return Property(propertyId: 4, isPrimaryKey: false)
    }
    
    public static var unsigned: Property<AllTypesEntity, UInt32, Void> {
        return Property(propertyId: 5, isPrimaryKey: false)
    }
    
    public static var double: Property<AllTypesEntity, Double, Void> {
        return Property(propertyId: 6, isPrimaryKey: false)
    }
    
    public static var string: Property<AllTypesEntity, String?, Void> {
        return Property(propertyId: 8, isPrimaryKey: false)
    }
    
    public static var date: Property<AllTypesEntity, Date?, Void> {
        return Property(propertyId: 7, isPrimaryKey: false)
    }
}

public class TestPersonCursor: EntityBinding {
    public typealias EntityType = TestPerson
    public typealias IdType = EntityId<TestPerson>

    public required init() {}

    public func setEntityIdUnlessStruct(of entity: TestPerson, to entityId: Id) {
        entity.id = EntityId(entityId)
    }
    
    public func entityId(of entity: TestPerson) -> Id {
        return entity.id.value
    }
    
    public func collect(fromEntity entity: TestPerson, id: Id, propertyCollector: FlatBufferBuilder,
                        store: Store) {
        let nameOffset = propertyCollector.prepare(string: entity.name)
        propertyCollector.collect(id, at: 4)
        propertyCollector.collect(entity.age, at: 6)
        propertyCollector.collect(dataOffset: nameOffset, at: 8)
    }
    
    public func createEntity(entityReader: FlatBufferReader, store: Store) -> TestPerson {
        let result = TestPerson()
        result.id = EntityId(entityReader.read(at: 4))
        result.age = entityReader.read(at: 6)
        result.name = entityReader.read(at: 8)
        return result
    }
}


public class AllTypesEntityCursor: EntityBinding {
    public typealias EntityType = AllTypesEntity
    public typealias IdType = EntityId<AllTypesEntity>

     public required init() {}

    public func setEntityIdUnlessStruct(of entity: AllTypesEntity, to entityId: Id) {
        entity.id = EntityId(entityId)
    }
    
    public func entityId(of entity: AllTypesEntity) -> Id {
        return entity.id.value
    }
    
     public func collect(fromEntity entity: AllTypesEntity, id: Id, propertyCollector: FlatBufferBuilder,
                         store: Store) {
        let offset = propertyCollector.prepare(string: entity.string)
        
        propertyCollector.collect(id, at: AllTypesOffset.ID.rawValue)
        propertyCollector.collect(entity.boolean, at: AllTypesOffset.bool.rawValue)
        propertyCollector.collect(entity.aLong, at: AllTypesOffset.long.rawValue)
        propertyCollector.collect(entity.integer, at: AllTypesOffset.integer.rawValue)
        propertyCollector.collect(entity.unsigned, at: AllTypesOffset.unsignedInteger.rawValue)
        propertyCollector.collect(entity.aDouble, at: AllTypesOffset.double.rawValue)
        propertyCollector.collect(entity.date, at: AllTypesOffset.date.rawValue)

        propertyCollector.collect(dataOffset: offset, at: AllTypesOffset.string.rawValue)
    }
    
     public func createEntity(entityReader: FlatBufferReader, store: Store) -> AllTypesEntity {
        let result = AllTypesEntity()
        
        result.id = EntityId(entityReader.read(at: AllTypesOffset.ID.rawValue))
        result.boolean = entityReader.read(at: AllTypesOffset.bool.rawValue)
        result.aLong = entityReader.read(at: AllTypesOffset.long.rawValue)
        result.integer = entityReader.read(at: AllTypesOffset.integer.rawValue)
        result.unsigned = entityReader.read(at: AllTypesOffset.unsignedInteger.rawValue)
        result.aDouble = entityReader.read(at: AllTypesOffset.double.rawValue)
        result.date = entityReader.read(at: AllTypesOffset.date.rawValue)
        result.string = entityReader.read(at: AllTypesOffset.string.rawValue)
        
        return result
    }
}

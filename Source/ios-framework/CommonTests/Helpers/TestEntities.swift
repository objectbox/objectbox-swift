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
public func createTestModel(syncEnabled: Bool = false) -> OpaquePointer {
    let modelBuilder = try! ModelBuilder()

    let allTypesEntityBuilder = try! modelBuilder.entityBuilder(for: AllTypesEntity.self, id: 1, uid: 1000)
    if syncEnabled {
        try! allTypesEntityBuilder.flags(.syncEnabled)
    }
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

    // Copied from actual generated entity info; which is clumsy...
    // Probably should clean up and just use generated entity info directly for all entity types.
    let entityBuilder = try! modelBuilder.entityBuilder(for: UniqueEntity.self, id: 7, uid: 6258744021471265280)
    try! entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 8418474383607017216)
    try! entityBuilder.addProperty(name: "name", type: PropertyType.string, flags: [.unique, .indexHash, .indexed], id: 2, uid: 6588651899515438336, indexId: 3, indexUid: 4943227758701996288)
    try! entityBuilder.addProperty(name: "content", type: PropertyType.string, id: 3, uid: 2295067898156422912)
    try! entityBuilder.addProperty(name: "content2", type: PropertyType.string, id: 4, uid: 8083811964173041920)
    try! entityBuilder.addProperty(name: "str1", type: PropertyType.string, id: 5, uid: 2085921255424893696)
    try! entityBuilder.addProperty(name: "str2", type: PropertyType.string, id: 6, uid: 3046539664613253632)
    try! entityBuilder.addProperty(name: "str3", type: PropertyType.string, id: 7, uid: 4836319770403460352)
    try! entityBuilder.addProperty(name: "str4", type: PropertyType.string, id: 8, uid: 5586670376507097344)
    try! entityBuilder.addProperty(name: "str5", type: PropertyType.string, id: 9, uid: 8779305452755862528)
    try! entityBuilder.addProperty(name: "str6", type: PropertyType.string, id: 10, uid: 7042629853749457152)
    try! entityBuilder.addProperty(name: "str7", type: PropertyType.string, id: 11, uid: 439706265026898176)
    try! entityBuilder.addProperty(name: "str8", type: PropertyType.string, id: 12, uid: 7797853325787760640)
    try! entityBuilder.addProperty(name: "str9", type: PropertyType.string, id: 13, uid: 6241625149586299904)
    try! entityBuilder.addProperty(name: "str10", type: PropertyType.string, id: 14, uid: 3838386263292640000)
    try! entityBuilder.addProperty(name: "str11", type: PropertyType.string, id: 15, uid: 2743032249190027008)
    try! entityBuilder.addProperty(name: "str12", type: PropertyType.string, id: 16, uid: 6199657977327115264)
    try! entityBuilder.addProperty(name: "str13", type: PropertyType.string, id: 17, uid: 6070699861433961728)
    try! entityBuilder.addProperty(name: "str14", type: PropertyType.string, id: 18, uid: 6029297771178376192)
    try! entityBuilder.addProperty(name: "str15", type: PropertyType.string, id: 19, uid: 3801959474204611328)
    try! entityBuilder.addProperty(name: "str16", type: PropertyType.string, id: 20, uid: 4774675437756918784)
    try! entityBuilder.addProperty(name: "str17", type: PropertyType.string, id: 21, uid: 8716823039315984640)
    try! entityBuilder.addProperty(name: "str18", type: PropertyType.string, id: 22, uid: 8894733078890829312)
    try! entityBuilder.addProperty(name: "str19", type: PropertyType.string, id: 23, uid: 1016331229052728320)
    try! entityBuilder.addProperty(name: "str20", type: PropertyType.string, id: 24, uid: 7810872262587479552)
    try! entityBuilder.addProperty(name: "str21", type: PropertyType.string, id: 25, uid: 4945264553128454912)
    try! entityBuilder.addProperty(name: "str22", type: PropertyType.string, id: 26, uid: 7152265273971458560)
    try! entityBuilder.addProperty(name: "str23", type: PropertyType.string, id: 27, uid: 6294538152931964672)
    try! entityBuilder.addProperty(name: "str24", type: PropertyType.string, id: 28, uid: 1939674925644995328)
    try! entityBuilder.addProperty(name: "str25", type: PropertyType.string, id: 29, uid: 2630803146682539264)
    try! entityBuilder.addProperty(name: "str26", type: PropertyType.string, id: 30, uid: 2158082104313626880)
    try! entityBuilder.addProperty(name: "str27", type: PropertyType.string, id: 31, uid: 4342475978535002368)
    try! entityBuilder.addProperty(name: "str28", type: PropertyType.string, id: 32, uid: 2618142912991854080)
    try! entityBuilder.addProperty(name: "str29", type: PropertyType.string, id: 33, uid: 4257312550012133632)
    try! entityBuilder.addProperty(name: "str30", type: PropertyType.string, id: 34, uid: 6658936396910379008)
    try! entityBuilder.addProperty(name: "str31", type: PropertyType.string, id: 35, uid: 7163695098896884992)
    try! entityBuilder.addProperty(name: "str32", type: PropertyType.string, id: 36, uid: 7792683921785881088)
    try! entityBuilder.addProperty(name: "str33", type: PropertyType.string, id: 37, uid: 2422385911045001728)
    try! entityBuilder.addProperty(name: "str34", type: PropertyType.string, id: 38, uid: 672123555343571712)
    try! entityBuilder.addProperty(name: "str35", type: PropertyType.string, id: 39, uid: 3356171792266690304)
    try! entityBuilder.addProperty(name: "str36", type: PropertyType.string, id: 40, uid: 8097607156277667584)
    try! entityBuilder.addProperty(name: "str37", type: PropertyType.string, id: 41, uid: 5877691172915301888)
    try! entityBuilder.addProperty(name: "str38", type: PropertyType.string, id: 42, uid: 7464585023102901248)
    try! entityBuilder.addProperty(name: "str39", type: PropertyType.string, id: 43, uid: 8211367673094595840)
    try! entityBuilder.addProperty(name: "str40", type: PropertyType.string, id: 44, uid: 123610260452597504)
    try! entityBuilder.addProperty(name: "str41", type: PropertyType.string, id: 45, uid: 2650611557939850240)
    try! entityBuilder.addProperty(name: "str42", type: PropertyType.string, id: 46, uid: 8393105718552925184)
    try! entityBuilder.addProperty(name: "str43", type: PropertyType.string, id: 47, uid: 6619994367521497344)
    try! entityBuilder.addProperty(name: "str44", type: PropertyType.string, id: 48, uid: 4805478268913715712)
    try! entityBuilder.addProperty(name: "str45", type: PropertyType.string, id: 49, uid: 8642866290657149184)
    try! entityBuilder.addProperty(name: "str46", type: PropertyType.string, id: 50, uid: 5061363131252470016)
    try! entityBuilder.addProperty(name: "str47", type: PropertyType.string, id: 51, uid: 4113947004423223040)
    try! entityBuilder.addProperty(name: "str48", type: PropertyType.string, id: 52, uid: 9141471831020050944)
    try! entityBuilder.addProperty(name: "str49", type: PropertyType.string, id: 53, uid: 938475961386865664)
    try! entityBuilder.addProperty(name: "str50", type: PropertyType.string, id: 54, uid: 2610097445773727232)
    try! entityBuilder.addProperty(name: "str51", type: PropertyType.string, id: 55, uid: 8223075157327230976)
    try! entityBuilder.addProperty(name: "str52", type: PropertyType.string, id: 56, uid: 6658701894057099520)
    try! entityBuilder.addProperty(name: "str53", type: PropertyType.string, id: 57, uid: 4320563155554460672)
    try! entityBuilder.addProperty(name: "str54", type: PropertyType.string, id: 58, uid: 3648783095476185088)
    try! entityBuilder.addProperty(name: "str55", type: PropertyType.string, id: 59, uid: 7718378802309229824)
    try! entityBuilder.addProperty(name: "str56", type: PropertyType.string, id: 60, uid: 7657786762797563392)
    try! entityBuilder.addProperty(name: "str57", type: PropertyType.string, id: 61, uid: 729766303749804544)
    try! entityBuilder.addProperty(name: "str58", type: PropertyType.string, id: 62, uid: 8250473843241116672)
    try! entityBuilder.addProperty(name: "str59", type: PropertyType.string, id: 63, uid: 4473980843763389184)
    try! entityBuilder.lastProperty(id: 63, uid: 4473980843763389184)

    modelBuilder.lastEntity(id: 7, uid: 6258744021471265280)
    modelBuilder.lastIndex(id: 3, uid: 4943227758701996288)

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

    public func generatorBindingVersion() -> Int { 1 }

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

    public func generatorBindingVersion() -> Int { 1 }

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

// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata


extension AnnotatedType: ObjectBox.__EntityRelatable {
    internal typealias EntityType = AnnotatedType

    internal var _id: EntityId<AnnotatedType> {
        return EntityId<AnnotatedType>(self.id.value)
    }
}

extension AnnotatedType: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = AnnotatedTypeBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "AnnotatedType", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: AnnotatedType.self, id: 1, uid: 21504)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 14592)
        try entityBuilder.addProperty(name: "flexData", type: PropertyType.flex, id: 2, uid: 15616)
        try entityBuilder.addProperty(name: "flexDataNullable", type: PropertyType.flex, id: 3, uid: 16640)
        try entityBuilder.addProperty(name: "flexByteArray", type: PropertyType.flex, id: 4, uid: 17664)
        try entityBuilder.addProperty(name: "dateValue", type: PropertyType.dateNano, id: 5, uid: 18688)
        try entityBuilder.addProperty(name: "dateNullable", type: PropertyType.dateNano, id: 6, uid: 19712)
        try entityBuilder.addProperty(name: "dateIdCompanion", type: PropertyType.dateNano, id: 7, uid: 20736)

        try entityBuilder.lastProperty(id: 7, uid: 20736)
    }
}

extension AnnotatedType {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { AnnotatedType.id == myId }
    internal static var id: Property<AnnotatedType, Id, Id> { return Property<AnnotatedType, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { AnnotatedType.flexData > 1234 }
    internal static var flexData: Property<AnnotatedType, Data, Void> { return Property<AnnotatedType, Data, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { AnnotatedType.flexDataNullable > 1234 }
    internal static var flexDataNullable: Property<AnnotatedType, Data?, Void> { return Property<AnnotatedType, Data?, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { AnnotatedType.flexByteArray > 1234 }
    internal static var flexByteArray: Property<AnnotatedType, [UInt8], Void> { return Property<AnnotatedType, [UInt8], Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { AnnotatedType.dateValue > 1234 }
    internal static var dateValue: Property<AnnotatedType, Date, Void> { return Property<AnnotatedType, Date, Void>(propertyId: 5, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { AnnotatedType.dateNullable > 1234 }
    internal static var dateNullable: Property<AnnotatedType, Date?, Void> { return Property<AnnotatedType, Date?, Void>(propertyId: 6, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { AnnotatedType.dateIdCompanion > 1234 }
    internal static var dateIdCompanion: Property<AnnotatedType, Date, Void> { return Property<AnnotatedType, Date, Void>(propertyId: 7, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == AnnotatedType {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<AnnotatedType, Id, Id> { return Property<AnnotatedType, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .flexData > 1234 }

    internal static var flexData: Property<AnnotatedType, Data, Void> { return Property<AnnotatedType, Data, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .flexDataNullable > 1234 }

    internal static var flexDataNullable: Property<AnnotatedType, Data?, Void> { return Property<AnnotatedType, Data?, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .flexByteArray > 1234 }

    internal static var flexByteArray: Property<AnnotatedType, [UInt8], Void> { return Property<AnnotatedType, [UInt8], Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .dateValue > 1234 }

    internal static var dateValue: Property<AnnotatedType, Date, Void> { return Property<AnnotatedType, Date, Void>(propertyId: 5, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .dateNullable > 1234 }

    internal static var dateNullable: Property<AnnotatedType, Date?, Void> { return Property<AnnotatedType, Date?, Void>(propertyId: 6, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .dateIdCompanion > 1234 }

    internal static var dateIdCompanion: Property<AnnotatedType, Date, Void> { return Property<AnnotatedType, Date, Void>(propertyId: 7, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `AnnotatedType.EntityBindingType`.
internal class AnnotatedTypeBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = AnnotatedType
    internal typealias IdType = Id

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_flexData = propertyCollector.prepare(bytes: entity.flexData)
        let propertyOffset_flexDataNullable = propertyCollector.prepare(bytes: entity.flexDataNullable)
        let propertyOffset_flexByteArray = propertyCollector.prepare(bytes: entity.flexByteArray)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collectNanos(entity.dateValue, at: 2 + 2 * 5)
        propertyCollector.collectNanos(entity.dateNullable, at: 2 + 2 * 6)
        propertyCollector.collectNanos(entity.dateIdCompanion, at: 2 + 2 * 7)
        propertyCollector.collect(dataOffset: propertyOffset_flexData, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_flexDataNullable, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_flexByteArray, at: 2 + 2 * 4)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = AnnotatedType()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.flexData = entityReader.read(at: 2 + 2 * 2)
        entity.flexDataNullable = entityReader.read(at: 2 + 2 * 3)
        entity.flexByteArray = entityReader.read(at: 2 + 2 * 4)
        entity.dateValue = entityReader.readNanos(at: 2 + 2 * 5)
        entity.dateNullable = entityReader.readNanos(at: 2 + 2 * 6)
        entity.dateIdCompanion = entityReader.readNanos(at: 2 + 2 * 7)

        return entity
    }
}



extension TypeTest: ObjectBox.__EntityRelatable {
    internal typealias EntityType = TypeTest

    internal var _id: EntityId<TypeTest> {
        return EntityId<TypeTest>(self.id.value)
    }
}

extension TypeTest: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = TypeTestBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "TypeTest", id: 2)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: TypeTest.self, id: 2, uid: 41728)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 22528)
        try entityBuilder.addProperty(name: "intValue", type: PropertyType.long, id: 2, uid: 23552)
        try entityBuilder.addProperty(name: "int8Value", type: PropertyType.byte, id: 3, uid: 24576)
        try entityBuilder.addProperty(name: "int16Value", type: PropertyType.short, id: 4, uid: 25600)
        try entityBuilder.addProperty(name: "int32Value", type: PropertyType.int, id: 5, uid: 26624)
        try entityBuilder.addProperty(name: "int64Value", type: PropertyType.long, id: 6, uid: 27648)
        try entityBuilder.addProperty(name: "uintValue", type: PropertyType.long, flags: [.unsigned], id: 7, uid: 28672)
        try entityBuilder.addProperty(name: "uint8Value", type: PropertyType.byte, flags: [.unsigned], id: 8, uid: 29696)
        try entityBuilder.addProperty(name: "uint16Value", type: PropertyType.short, flags: [.unsigned], id: 9, uid: 30720)
        try entityBuilder.addProperty(name: "uint32Value", type: PropertyType.int, flags: [.unsigned], id: 10, uid: 31744)
        try entityBuilder.addProperty(name: "uint64Value", type: PropertyType.long, flags: [.unsigned], id: 11, uid: 32512)
        try entityBuilder.addProperty(name: "boolValue", type: PropertyType.bool, id: 12, uid: 33536)
        try entityBuilder.addProperty(name: "stringValue", type: PropertyType.string, id: 13, uid: 34560)
        try entityBuilder.addProperty(name: "byteValue", type: Byte.entityPropertyType, id: 14, uid: 35584)
        try entityBuilder.addProperty(name: "bytes", type: PropertyType.byteVector, id: 15, uid: 36608)
        try entityBuilder.addProperty(name: "byteArray", type: PropertyType.byteVector, id: 16, uid: 37632)
        try entityBuilder.addProperty(name: "floatValue", type: PropertyType.float, id: 17, uid: 38656)
        try entityBuilder.addProperty(name: "doubleValue", type: PropertyType.double, id: 18, uid: 39680)
        try entityBuilder.addProperty(name: "dateValue", type: PropertyType.date, id: 19, uid: 40704)

        try entityBuilder.lastProperty(id: 19, uid: 40704)
    }
}

extension TypeTest {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.id == myId }
    internal static var id: Property<TypeTest, EntityId<TypeTest>, EntityId<TypeTest>> { return Property<TypeTest, EntityId<TypeTest>, EntityId<TypeTest>>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.intValue > 1234 }
    internal static var intValue: Property<TypeTest, Int, Void> { return Property<TypeTest, Int, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.int8Value > 1234 }
    internal static var int8Value: Property<TypeTest, Int8, Void> { return Property<TypeTest, Int8, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.int16Value > 1234 }
    internal static var int16Value: Property<TypeTest, Int16, Void> { return Property<TypeTest, Int16, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.int32Value > 1234 }
    internal static var int32Value: Property<TypeTest, Int32, Void> { return Property<TypeTest, Int32, Void>(propertyId: 5, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.int64Value > 1234 }
    internal static var int64Value: Property<TypeTest, Int64, Void> { return Property<TypeTest, Int64, Void>(propertyId: 6, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.uintValue > 1234 }
    internal static var uintValue: Property<TypeTest, UInt, Void> { return Property<TypeTest, UInt, Void>(propertyId: 7, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.uint8Value > 1234 }
    internal static var uint8Value: Property<TypeTest, UInt8, Void> { return Property<TypeTest, UInt8, Void>(propertyId: 8, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.uint16Value > 1234 }
    internal static var uint16Value: Property<TypeTest, UInt16, Void> { return Property<TypeTest, UInt16, Void>(propertyId: 9, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.uint32Value > 1234 }
    internal static var uint32Value: Property<TypeTest, UInt32, Void> { return Property<TypeTest, UInt32, Void>(propertyId: 10, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.uint64Value > 1234 }
    internal static var uint64Value: Property<TypeTest, UInt64, Void> { return Property<TypeTest, UInt64, Void>(propertyId: 11, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.boolValue == true }
    internal static var boolValue: Property<TypeTest, Bool, Void> { return Property<TypeTest, Bool, Void>(propertyId: 12, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.stringValue.startsWith("X") }
    internal static var stringValue: Property<TypeTest, String, Void> { return Property<TypeTest, String, Void>(propertyId: 13, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.byteValue > 1234 }
    internal static var byteValue: Property<TypeTest, Byte, Void> { return Property<TypeTest, Byte, Void>(propertyId: 14, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.bytes > 1234 }
    internal static var bytes: Property<TypeTest, Data, Void> { return Property<TypeTest, Data, Void>(propertyId: 15, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.byteArray > 1234 }
    internal static var byteArray: Property<TypeTest, Data, Void> { return Property<TypeTest, Data, Void>(propertyId: 16, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.floatValue > 1234 }
    internal static var floatValue: Property<TypeTest, Float, Void> { return Property<TypeTest, Float, Void>(propertyId: 17, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.doubleValue > 1234 }
    internal static var doubleValue: Property<TypeTest, Double, Void> { return Property<TypeTest, Double, Void>(propertyId: 18, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { TypeTest.dateValue > 1234 }
    internal static var dateValue: Property<TypeTest, Date, Void> { return Property<TypeTest, Date, Void>(propertyId: 19, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = EntityId(identifier)
    }
}

extension ObjectBox.Property where E == TypeTest {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<TypeTest, EntityId<TypeTest>, EntityId<TypeTest>> { return Property<TypeTest, EntityId<TypeTest>, EntityId<TypeTest>>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .intValue > 1234 }

    internal static var intValue: Property<TypeTest, Int, Void> { return Property<TypeTest, Int, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .int8Value > 1234 }

    internal static var int8Value: Property<TypeTest, Int8, Void> { return Property<TypeTest, Int8, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .int16Value > 1234 }

    internal static var int16Value: Property<TypeTest, Int16, Void> { return Property<TypeTest, Int16, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .int32Value > 1234 }

    internal static var int32Value: Property<TypeTest, Int32, Void> { return Property<TypeTest, Int32, Void>(propertyId: 5, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .int64Value > 1234 }

    internal static var int64Value: Property<TypeTest, Int64, Void> { return Property<TypeTest, Int64, Void>(propertyId: 6, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .uintValue > 1234 }

    internal static var uintValue: Property<TypeTest, UInt, Void> { return Property<TypeTest, UInt, Void>(propertyId: 7, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .uint8Value > 1234 }

    internal static var uint8Value: Property<TypeTest, UInt8, Void> { return Property<TypeTest, UInt8, Void>(propertyId: 8, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .uint16Value > 1234 }

    internal static var uint16Value: Property<TypeTest, UInt16, Void> { return Property<TypeTest, UInt16, Void>(propertyId: 9, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .uint32Value > 1234 }

    internal static var uint32Value: Property<TypeTest, UInt32, Void> { return Property<TypeTest, UInt32, Void>(propertyId: 10, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .uint64Value > 1234 }

    internal static var uint64Value: Property<TypeTest, UInt64, Void> { return Property<TypeTest, UInt64, Void>(propertyId: 11, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .boolValue == true }

    internal static var boolValue: Property<TypeTest, Bool, Void> { return Property<TypeTest, Bool, Void>(propertyId: 12, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .stringValue.startsWith("X") }

    internal static var stringValue: Property<TypeTest, String, Void> { return Property<TypeTest, String, Void>(propertyId: 13, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .byteValue > 1234 }

    internal static var byteValue: Property<TypeTest, Byte, Void> { return Property<TypeTest, Byte, Void>(propertyId: 14, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .bytes > 1234 }

    internal static var bytes: Property<TypeTest, Data, Void> { return Property<TypeTest, Data, Void>(propertyId: 15, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .byteArray > 1234 }

    internal static var byteArray: Property<TypeTest, Data, Void> { return Property<TypeTest, Data, Void>(propertyId: 16, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .floatValue > 1234 }

    internal static var floatValue: Property<TypeTest, Float, Void> { return Property<TypeTest, Float, Void>(propertyId: 17, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .doubleValue > 1234 }

    internal static var doubleValue: Property<TypeTest, Double, Void> { return Property<TypeTest, Double, Void>(propertyId: 18, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .dateValue > 1234 }

    internal static var dateValue: Property<TypeTest, Date, Void> { return Property<TypeTest, Date, Void>(propertyId: 19, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `TypeTest.EntityBindingType`.
internal class TypeTestBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = TypeTest
    internal typealias IdType = EntityId<TypeTest>

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_stringValue = propertyCollector.prepare(string: entity.stringValue)
        let propertyOffset_bytes = propertyCollector.prepare(bytes: entity.bytes)
        let propertyOffset_byteArray = propertyCollector.prepare(bytes: entity.byteArray)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.intValue, at: 2 + 2 * 2)
        propertyCollector.collect(entity.int8Value, at: 2 + 2 * 3)
        propertyCollector.collect(entity.int16Value, at: 2 + 2 * 4)
        propertyCollector.collect(entity.int32Value, at: 2 + 2 * 5)
        propertyCollector.collect(entity.int64Value, at: 2 + 2 * 6)
        propertyCollector.collect(entity.uintValue, at: 2 + 2 * 7)
        propertyCollector.collect(entity.uint8Value, at: 2 + 2 * 8)
        propertyCollector.collect(entity.uint16Value, at: 2 + 2 * 9)
        propertyCollector.collect(entity.uint32Value, at: 2 + 2 * 10)
        propertyCollector.collect(entity.uint64Value, at: 2 + 2 * 11)
        propertyCollector.collect(entity.boolValue, at: 2 + 2 * 12)
        propertyCollector.collect(entity.byteValue, at: 2 + 2 * 14)
        propertyCollector.collect(entity.floatValue, at: 2 + 2 * 17)
        propertyCollector.collect(entity.doubleValue, at: 2 + 2 * 18)
        propertyCollector.collect(entity.dateValue, at: 2 + 2 * 19)
        propertyCollector.collect(dataOffset: propertyOffset_stringValue, at: 2 + 2 * 13)
        propertyCollector.collect(dataOffset: propertyOffset_bytes, at: 2 + 2 * 15)
        propertyCollector.collect(dataOffset: propertyOffset_byteArray, at: 2 + 2 * 16)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = TypeTest()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.intValue = entityReader.read(at: 2 + 2 * 2)
        entity.int8Value = entityReader.read(at: 2 + 2 * 3)
        entity.int16Value = entityReader.read(at: 2 + 2 * 4)
        entity.int32Value = entityReader.read(at: 2 + 2 * 5)
        entity.int64Value = entityReader.read(at: 2 + 2 * 6)
        entity.uintValue = entityReader.read(at: 2 + 2 * 7)
        entity.uint8Value = entityReader.read(at: 2 + 2 * 8)
        entity.uint16Value = entityReader.read(at: 2 + 2 * 9)
        entity.uint32Value = entityReader.read(at: 2 + 2 * 10)
        entity.uint64Value = entityReader.read(at: 2 + 2 * 11)
        entity.boolValue = entityReader.read(at: 2 + 2 * 12)
        entity.stringValue = entityReader.read(at: 2 + 2 * 13)
        entity.byteValue = entityReader.read(at: 2 + 2 * 14)
        entity.bytes = entityReader.read(at: 2 + 2 * 15)
        entity.byteArray = entityReader.read(at: 2 + 2 * 16)
        entity.floatValue = entityReader.read(at: 2 + 2 * 17)
        entity.doubleValue = entityReader.read(at: 2 + 2 * 18)
        entity.dateValue = entityReader.read(at: 2 + 2 * 19)

        return entity
    }
}


/// Helper function that allows calling Enum(rawValue: value) with a nil value, which will return nil.
fileprivate func optConstruct<T: RawRepresentable>(_ type: T.Type, rawValue: T.RawValue?) -> T? {
    guard let rawValue = rawValue else { return nil }
    return T(rawValue: rawValue)
}

// MARK: - Store setup

fileprivate func cModel() throws -> OpaquePointer {
    let modelBuilder = try ObjectBox.ModelBuilder()
    try AnnotatedType.buildEntity(modelBuilder: modelBuilder)
    try TypeTest.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 2, uid: 41728)
    return modelBuilder.finish()
}

extension ObjectBox.Store {
    /// A store with a fully configured model. Created by the code generator with your model's metadata in place.
    ///
    /// # In-memory database
    /// To use a file-less in-memory database, instead of a directory path pass `memory:` 
    /// together with an identifier string:
    /// ```swift
    /// let inMemoryStore = try Store(directoryPath: "memory:test-db")
    /// ```
    ///
    /// - Parameters:
    ///   - directoryPath: The directory path in which ObjectBox places its database files for this store,
    ///     or to use an in-memory database `memory:<identifier>`.
    ///   - maxDbSizeInKByte: Limit of on-disk space for the database files. Default is `1024 * 1024` (1 GiB).
    ///   - fileMode: UNIX-style bit mask used for the database files; default is `0o644`.
    ///     Note: directories become searchable if the "read" or "write" permission is set (e.g. 0640 becomes 0750).
    ///   - maxReaders: The maximum number of readers.
    ///     "Readers" are a finite resource for which we need to define a maximum number upfront.
    ///     The default value is enough for most apps and usually you can ignore it completely.
    ///     However, if you get the maxReadersExceeded error, you should verify your
    ///     threading. For each thread, ObjectBox uses multiple readers. Their number (per thread) depends
    ///     on number of types, relations, and usage patterns. Thus, if you are working with many threads
    ///     (e.g. in a server-like scenario), it can make sense to increase the maximum number of readers.
    ///     Note: The internal default is currently around 120. So when hitting this limit, try values around 200-500.
    ///   - readOnly: Opens the database in read-only mode, i.e. not allowing write transactions.
    ///
    /// - important: This initializer is created by the code generator. If you only see the internal `init(model:...)`
    ///              initializer, trigger code generation by building your project.
    internal convenience init(directoryPath: String, maxDbSizeInKByte: UInt64 = 1024 * 1024,
                            fileMode: UInt32 = 0o644, maxReaders: UInt32 = 0, readOnly: Bool = false) throws {
        try self.init(
            model: try cModel(),
            directory: directoryPath,
            maxDbSizeInKByte: maxDbSizeInKByte,
            fileMode: fileMode,
            maxReaders: maxReaders,
            readOnly: readOnly)
    }
}

// swiftlint:enable all

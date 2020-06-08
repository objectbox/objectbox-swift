// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox

// MARK: - Entity metadata


extension DataThing: ObjectBox.__EntityRelatable {
    internal typealias EntityType = DataThing

    internal var _id: EntityId<DataThing> {
        return EntityId<DataThing>(self.id.value)
    }
}

extension DataThing: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = DataThingBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "DataThing", id: 2)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: DataThing.self, id: 2, uid: 23552)
        try entityBuilder.addProperty(name: "id", type: EntityId<DataThing>.entityPropertyType, flags: [.id], id: 1, uid: 18688)
        try entityBuilder.addProperty(name: "firstData", type: Data.entityPropertyType, id: 2, uid: 19712)
        try entityBuilder.addProperty(name: "secondData", type: [UInt8].entityPropertyType, id: 3, uid: 20736)
        try entityBuilder.addProperty(name: "maybeThirdData", type: Data.entityPropertyType, id: 4, uid: 21504)
        try entityBuilder.addProperty(name: "maybeFourthData", type: [UInt8].entityPropertyType, id: 5, uid: 22528)

        try entityBuilder.lastProperty(id: 5, uid: 22528)
    }
}

extension DataThing {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { DataThing.id == myId }
    internal static var id: Property<DataThing, EntityId<DataThing>, EntityId<DataThing>> { return Property<DataThing, EntityId<DataThing>, EntityId<DataThing>>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { DataThing.firstData > 1234 }
    internal static var firstData: Property<DataThing, Data, Void> { return Property<DataThing, Data, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { DataThing.secondData > 1234 }
    internal static var secondData: Property<DataThing, [UInt8], Void> { return Property<DataThing, [UInt8], Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { DataThing.maybeThirdData > 1234 }
    internal static var maybeThirdData: Property<DataThing, Data?, Void> { return Property<DataThing, Data?, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { DataThing.maybeFourthData > 1234 }
    internal static var maybeFourthData: Property<DataThing, [UInt8]?, Void> { return Property<DataThing, [UInt8]?, Void>(propertyId: 5, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = EntityId(identifier)
    }
}

extension ObjectBox.Property where E == DataThing {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<DataThing, EntityId<DataThing>, EntityId<DataThing>> { return Property<DataThing, EntityId<DataThing>, EntityId<DataThing>>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .firstData > 1234 }

    internal static var firstData: Property<DataThing, Data, Void> { return Property<DataThing, Data, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .secondData > 1234 }

    internal static var secondData: Property<DataThing, [UInt8], Void> { return Property<DataThing, [UInt8], Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .maybeThirdData > 1234 }

    internal static var maybeThirdData: Property<DataThing, Data?, Void> { return Property<DataThing, Data?, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .maybeFourthData > 1234 }

    internal static var maybeFourthData: Property<DataThing, [UInt8]?, Void> { return Property<DataThing, [UInt8]?, Void>(propertyId: 5, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `DataThing.EntityBindingType`.
internal class DataThingBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = DataThing
    internal typealias IdType = EntityId<DataThing>

    override internal required init() {}

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) {
        let propertyOffset_firstData = propertyCollector.prepare(bytes: entity.firstData)
        let propertyOffset_secondData = propertyCollector.prepare(bytes: entity.secondData)
        let propertyOffset_maybeThirdData = propertyCollector.prepare(bytes: entity.maybeThirdData)
        let propertyOffset_maybeFourthData = propertyCollector.prepare(bytes: entity.maybeFourthData)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_firstData, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_secondData, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_maybeThirdData, at: 2 + 2 * 4)
        propertyCollector.collect(dataOffset: propertyOffset_maybeFourthData, at: 2 + 2 * 5)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = DataThing()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.firstData = entityReader.read(at: 2 + 2 * 2)
        entity.secondData = entityReader.read(at: 2 + 2 * 3)
        entity.maybeThirdData = entityReader.read(at: 2 + 2 * 4)
        entity.maybeFourthData = entityReader.read(at: 2 + 2 * 5)

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
    try DataThing.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 2, uid: 23552)
    return modelBuilder.finish()
}

extension ObjectBox.Store {
    /// A store with a fully configured model. Created by the code generator with your model's metadata in place.
    ///
    /// - Parameters:
    ///   - directoryPath: Directory path to store database files in.
    ///   - maxDbSizeInKByte: Limit of on-disk space for the database files. Default is `1024 * 1024` (1 GiB).
    ///   - fileMode: UNIX-style bit mask used for the database files; default is `0o755`.
    ///   - maxReaders: Maximum amount of concurrent readers, tailored to your use case. Default is `0` (unlimited).
    internal convenience init(directoryPath: String, maxDbSizeInKByte: UInt64 = 1024 * 1024, fileMode: UInt32 = 0o755, maxReaders: UInt32 = 0) throws {
        try self.init(
            model: try cModel(),
            directory: directoryPath,
            maxDbSizeInKByte: maxDbSizeInKByte,
            fileMode: fileMode,
            maxReaders: maxReaders)
    }
}

// swiftlint:enable all

// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox

// MARK: - Entity metadata


extension Autobus: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Autobus

    internal var _id: EntityId<Autobus> {
        return EntityId<Autobus>(self.id.value)
    }
}

extension Autobus: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = AutobusBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Autobus", id: 3)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Autobus.self, id: 3, uid: 25600)
        try entityBuilder.addProperty(name: "id", type: EntityId<Autobus>.entityPropertyType, flags: [.id], id: 1, uid: 23552)
        try entityBuilder.addProperty(name: "lineName", type: String.entityPropertyType, id: 2, uid: 24576)

        try entityBuilder.lastProperty(id: 2, uid: 24576)
    }
}

extension Autobus {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Autobus.id == myId }
    internal static var id: Property<Autobus, EntityId<Autobus>, EntityId<Autobus>> { return Property<Autobus, EntityId<Autobus>, EntityId<Autobus>>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Autobus.lineName.startsWith("X") }
    internal static var lineName: Property<Autobus, String, Void> { return Property<Autobus, String, Void>(propertyId: 2, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = EntityId(identifier)
    }
}

extension ObjectBox.Property where E == Autobus {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Autobus, EntityId<Autobus>, EntityId<Autobus>> { return Property<Autobus, EntityId<Autobus>, EntityId<Autobus>>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .lineName.startsWith("X") }

    internal static var lineName: Property<Autobus, String, Void> { return Property<Autobus, String, Void>(propertyId: 2, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Autobus.EntityBindingType`.
internal class AutobusBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = Autobus
    internal typealias IdType = EntityId<Autobus>

    override internal required init() {}

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) {
        let propertyOffset_lineName = propertyCollector.prepare(string: entity.lineName)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_lineName, at: 2 + 2 * 2)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Autobus()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.lineName = entityReader.read(at: 2 + 2 * 2)

        return entity
    }
}



extension Building: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Building

    internal var _id: EntityId<Building> {
        return EntityId<Building>(self.id.value)
    }
}

extension Building: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = BuildingBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Building", id: 2)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Building.self, id: 2, uid: 22528)
        try entityBuilder.addProperty(name: "id", type: EntityId<Building>.entityPropertyType, flags: [.id], id: 1, uid: 19712)
        try entityBuilder.addProperty(name: "buildingName", type: String.entityPropertyType, id: 2, uid: 20736)
        try entityBuilder.addProperty(name: "buildingNumber", type: Int.entityPropertyType, id: 3, uid: 21504)

        try entityBuilder.lastProperty(id: 3, uid: 21504)
    }
}

extension Building {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Building.id == myId }
    internal static var id: Property<Building, EntityId<Building>, EntityId<Building>> { return Property<Building, EntityId<Building>, EntityId<Building>>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Building.buildingName.startsWith("X") }
    internal static var buildingName: Property<Building, String, Void> { return Property<Building, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Building.buildingNumber > 1234 }
    internal static var buildingNumber: Property<Building, Int, Void> { return Property<Building, Int, Void>(propertyId: 3, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = EntityId(identifier)
    }
}

extension ObjectBox.Property where E == Building {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Building, EntityId<Building>, EntityId<Building>> { return Property<Building, EntityId<Building>, EntityId<Building>>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .buildingName.startsWith("X") }

    internal static var buildingName: Property<Building, String, Void> { return Property<Building, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .buildingNumber > 1234 }

    internal static var buildingNumber: Property<Building, Int, Void> { return Property<Building, Int, Void>(propertyId: 3, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Building.EntityBindingType`.
internal class BuildingBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = Building
    internal typealias IdType = EntityId<Building>

    override internal required init() {}

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) {
        let propertyOffset_buildingName = propertyCollector.prepare(string: entity.buildingName)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.buildingNumber, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_buildingName, at: 2 + 2 * 2)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Building()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.buildingName = entityReader.read(at: 2 + 2 * 2)
        entity.buildingNumber = entityReader.read(at: 2 + 2 * 3)

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
    try Autobus.buildEntity(modelBuilder: modelBuilder)
    try Building.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 3, uid: 25600)
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

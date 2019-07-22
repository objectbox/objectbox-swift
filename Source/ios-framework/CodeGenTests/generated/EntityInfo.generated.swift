// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT
// swiftlint:disable all
import ObjectBox

// MARK: - Entity metadata


extension Building: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Building

    internal var _id: Id<Building> {
        return Id<Building>(self.id)
    }
}

extension Building: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = BuildingBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Building", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Building.self, id: 1, uid: 17664)
        try entityBuilder.addProperty(name: "id", type: UInt64.entityPropertyType, flags: [.id, .unsigned], id: 1, uid: 14592)
        try entityBuilder.addProperty(name: "buildingName", type: String.entityPropertyType, id: 2, uid: 15616)
        try entityBuilder.addProperty(name: "buildingNumber", type: Int.entityPropertyType, id: 3, uid: 16640)

        try entityBuilder.lastProperty(id: 3, uid: 16640)
    }
}

extension Building {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Building.id == myId }
    internal static var id: Property<Building, UInt64> { return Property<Building, UInt64>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Building.buildingName.startsWith("X") }
    internal static var buildingName: Property<Building, String> { return Property<Building, String>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Building.buildingNumber > 1234 }
    internal static var buildingNumber: Property<Building, Int> { return Property<Building, Int>(propertyId: 3, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.EntityId) {
        self.id = UInt64(identifier)
    }
}

extension ObjectBox.Property where E == Building {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    static var id: Property<Building, UInt64> { return Property<Building, UInt64>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .buildingName.startsWith("X") }

    static var buildingName: Property<Building, String> { return Property<Building, String>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .buildingNumber > 1234 }

    static var buildingNumber: Property<Building, Int> { return Property<Building, Int>(propertyId: 3, isPrimaryKey: false) }


}


/// Generated service type to handle persisting and reading entity data. Exposed through `Building.EntityBindingType`.
internal class BuildingBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = Building

    override internal required init() {}

    internal func setEntityId(of entity: EntityType, to entityId: ObjectBox.EntityId) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.EntityId {
        return ObjectBox.EntityId(entity.id)
    }

    internal func collect(fromEntity entity: EntityType, id: EntityId, propertyCollector: PropertyCollector, store: Store) {

        var offsets: [(offset: OBXDataOffset, index: UInt16)] = []
        offsets.append((propertyCollector.prepare(string: entity.buildingName, at: 2 + 2 * 2), 2 + 2 * 2))

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.buildingNumber, at: 2 + 2 * 3)


        for value in offsets {
            propertyCollector.collect(dataOffset: value.offset, at: value.index)
        }
    }

    internal func createEntity(entityReader: EntityReader, store: Store) -> EntityType {
        let entity = Building()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.buildingName = entityReader.read(at: 2 + 2 * 2)
        entity.buildingNumber = entityReader.read(at: 2 + 2 * 3)



        return entity
    }
}



// MARK: - Store setup

fileprivate func cModel() throws -> OpaquePointer {
    let modelBuilder = try ModelBuilder()
    try Building.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 1, uid: 17664)
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

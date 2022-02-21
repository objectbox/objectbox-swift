// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata


extension Building: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Building

    internal var _id: EntityId<Building> {
        return EntityId<Building>(self.id.value)
    }
}

extension Building: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = BuildingBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Building", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Building.self, id: 1, uid: 17664)
        try entityBuilder.addProperty(name: "id", type: UInt64.entityPropertyType, flags: [.id], id: 1, uid: 14592)
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
    internal static var id: Property<Building, UInt64, UInt64> { return Property<Building, UInt64, UInt64>(propertyId: 1, isPrimaryKey: true) }
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
        self.id = UInt64(identifier)
    }
}

extension ObjectBox.Property where E == Building {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Building, UInt64, UInt64> { return Property<Building, UInt64, UInt64>(propertyId: 1, isPrimaryKey: true) }

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
internal class BuildingBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = Building
    internal typealias IdType = UInt64

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
    try Building.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 1, uid: 17664)
    return modelBuilder.finish()
}

extension ObjectBox.Store {
    /// A store with a fully configured model. Created by the code generator with your model's metadata in place.
    ///
    /// - Parameters:
    ///   - directoryPath: The directory path in which ObjectBox places its database files for this store.
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
    ///     Note: The internal default is currently around 120.
    ///           So when hitting this limit, try values around 200-500.
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
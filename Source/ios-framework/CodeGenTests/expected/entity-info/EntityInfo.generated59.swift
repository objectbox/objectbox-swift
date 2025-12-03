// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata

extension CityAllProperties: ObjectBox.Entity {}
extension CityDefaults: ObjectBox.Entity {}

extension CityAllProperties: ObjectBox.__EntityRelatable {
    internal typealias EntityType = CityAllProperties

    internal var _id: EntityId<CityAllProperties> {
        return EntityId<CityAllProperties>(self.id.value)
    }
}

extension CityAllProperties: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = CityAllPropertiesBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static let entityInfo = ObjectBox.EntityInfo(name: "CityAllProperties", id: 1)

    internal static let entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: CityAllProperties.self, id: 1, uid: 17664)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 14592)
        try entityBuilder.addProperty(name: "coordinates", type: PropertyType.floatVector, flags: [.indexed], id: 2, uid: 16640, indexId: 1, indexUid: 15616)
            .hnswParams(dimensions: 2, neighborsPerNode: 30, indexingSearchCount: 100, flags: [HnswFlags.debugLogs, HnswFlags.debugLogsDetailed, HnswFlags.reparationLimitCandidates, HnswFlags.vectorCacheSimdPaddingOff], distanceType: HnswDistanceType.geo, reparationBacklinkProbability: 0.95, vectorCacheHintSizeKB: 2097152)

        try entityBuilder.lastProperty(id: 2, uid: 16640)
    }
}

extension CityAllProperties {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { CityAllProperties.id == myId }
    internal static var id: Property<CityAllProperties, Id, Id> { return Property<CityAllProperties, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { CityAllProperties.coordinates.isGreaterThan(value) }
    internal static var coordinates: Property<CityAllProperties, HnswIndexPropertyType, Void> { return Property<CityAllProperties, HnswIndexPropertyType, Void>(propertyId: 2, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == CityAllProperties {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<CityAllProperties, Id, Id> { return Property<CityAllProperties, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .coordinates.isNotNil() }

    internal static var coordinates: Property<CityAllProperties, HnswIndexPropertyType, Void> { return Property<CityAllProperties, HnswIndexPropertyType, Void>(propertyId: 2, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `CityAllProperties.EntityBindingType`.
internal final class CityAllPropertiesBinding: ObjectBox.EntityBinding, Sendable {
    internal typealias EntityType = CityAllProperties
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
        let propertyOffset_coordinates = propertyCollector.prepare(values: entity.coordinates)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_coordinates, at: 2 + 2 * 2)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = CityAllProperties()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.coordinates = entityReader.read(at: 2 + 2 * 2)

        return entity
    }
}



extension CityDefaults: ObjectBox.__EntityRelatable {
    internal typealias EntityType = CityDefaults

    internal var _id: EntityId<CityDefaults> {
        return EntityId<CityDefaults>(self.id.value)
    }
}

extension CityDefaults: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = CityDefaultsBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static let entityInfo = ObjectBox.EntityInfo(name: "CityDefaults", id: 2)

    internal static let entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: CityDefaults.self, id: 2, uid: 21504)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 18688)
        try entityBuilder.addProperty(name: "coordinatesDefaults", type: PropertyType.floatVector, flags: [.indexed], id: 2, uid: 20736, indexId: 2, indexUid: 19712)
            .hnswParams(dimensions: 2, neighborsPerNode: nil, indexingSearchCount: nil, flags: nil, distanceType: nil, reparationBacklinkProbability: nil, vectorCacheHintSizeKB: nil)

        try entityBuilder.lastProperty(id: 2, uid: 20736)
    }
}

extension CityDefaults {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { CityDefaults.id == myId }
    internal static var id: Property<CityDefaults, Id, Id> { return Property<CityDefaults, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { CityDefaults.coordinatesDefaults.isGreaterThan(value) }
    internal static var coordinatesDefaults: Property<CityDefaults, HnswIndexPropertyType, Void> { return Property<CityDefaults, HnswIndexPropertyType, Void>(propertyId: 2, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == CityDefaults {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<CityDefaults, Id, Id> { return Property<CityDefaults, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .coordinatesDefaults.isNotNil() }

    internal static var coordinatesDefaults: Property<CityDefaults, HnswIndexPropertyType, Void> { return Property<CityDefaults, HnswIndexPropertyType, Void>(propertyId: 2, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `CityDefaults.EntityBindingType`.
internal final class CityDefaultsBinding: ObjectBox.EntityBinding, Sendable {
    internal typealias EntityType = CityDefaults
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
        let propertyOffset_coordinatesDefaults = propertyCollector.prepare(values: entity.coordinatesDefaults)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_coordinatesDefaults, at: 2 + 2 * 2)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = CityDefaults()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.coordinatesDefaults = entityReader.read(at: 2 + 2 * 2)

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
    try CityAllProperties.buildEntity(modelBuilder: modelBuilder)
    try CityDefaults.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 2, uid: 21504)
    modelBuilder.lastIndex(id: 2, uid: 19712)
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

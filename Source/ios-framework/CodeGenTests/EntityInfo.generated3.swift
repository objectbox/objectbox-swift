// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox

// MARK: - Entity metadata

extension BusRoute: ObjectBox.Entity {}

extension BusRoute: ObjectBox.__EntityRelatable {
    internal typealias EntityType = BusRoute

    internal var _id: EntityId<BusRoute> {
        return EntityId<BusRoute>(self.id.value)
    }
}

extension BusRoute: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = BusRouteBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "BusRoute", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: BusRoute.self, id: 1, uid: 5107964062888457216)
        try entityBuilder.addProperty(name: "id", type: EntityId<BusRoute>.entityPropertyType, flags: [.id], id: 1, uid: 7895576389419683840)

        try entityBuilder.lastProperty(id: 2, uid: 6687926154759915520)
    }
}

extension BusRoute {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { BusRoute.id == myId }
    internal static var id: Property<BusRoute, EntityId<BusRoute>, EntityId<BusRoute>> { return Property<BusRoute, EntityId<BusRoute>, EntityId<BusRoute>>(propertyId: 1, isPrimaryKey: true) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = EntityId(identifier)
    }
}

extension ObjectBox.Property where E == BusRoute {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<BusRoute, EntityId<BusRoute>, EntityId<BusRoute>> { return Property<BusRoute, EntityId<BusRoute>, EntityId<BusRoute>>(propertyId: 1, isPrimaryKey: true) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `BusRoute.EntityBindingType`.
internal class BusRouteBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = BusRoute
    internal typealias IdType = EntityId<BusRoute>

    override internal required init() {}

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) {

        propertyCollector.collect(id, at: 2 + 2 * 1)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = BusRoute()

        entity.id = entityReader.read(at: 2 + 2 * 1)

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
    try BusRoute.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 1, uid: 5107964062888457216)
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

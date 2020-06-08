// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox

// MARK: - Entity metadata


extension BusRoute: __EntityRelatable {
    typealias EntityType = BusRoute

    var _id: Id<BusRoute> {
        return self.id
    }
}

extension BusRoute: EntityInspectable {
    /// Generated metadata used by ObjectBox to persist the entity.
    static var entityInfo: EntityInfo {
        return EntityInfo(
            name: "BusRoute",
            cursorClass: BusRouteCursor.self)
    }

    fileprivate static func buildEntity(modelBuilder: ModelBuilder) {
        let entityBuilder = modelBuilder.entityBuilder(for: entityInfo, uid: 17664)
        entityBuilder.addProperty(name: "id", type: Id<BusRoute>.entityPropertyType, flags: [.id], uid: 14592)
        entityBuilder.addProperty(name: "lineName", type: String.entityPropertyType, uid: 16640)
        entityBuilder.addProperty(name: "destinationName", type: String.entityPropertyType, uid: 18688)

    }
}

extension BusRoute {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { BusRoute.id == myId }
    static var id: Property<BusRoute, Id<BusRoute>> { return Property<BusRoute, Id<BusRoute>>(propertyId: 14592, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { BusRoute.lineName.startsWith("X") }
    static var lineName: Property<BusRoute, String> { return Property<BusRoute, String>(propertyId: 16640, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { BusRoute.destinationName.startsWith("X") }
    static var destinationName: Property<BusRoute, String> { return Property<BusRoute, String>(propertyId: 18688, isPrimaryKey: false) }

    fileprivate  func __setId(identifier: EntityId) {
        self.id = Id(identifier)
    }
}

/// Generated service type to handle persisting and reading entity data. Exposed through `BusRoute.entityInfo`.
class BusRouteCursor: NSObject, CursorBase {
    func setEntityIdUnlessStruct(of entity: Any, to entityId: EntityId) {
        let entity = entity as! BusRoute
        entity.__setId(identifier: entityId)
    }

    func entityId(of entity: Any) -> EntityId {
        let entity = entity as! BusRoute
        return entity.id.value
    }

    func collect(fromEntity entity: Any, propertyCollector: PropertyCollector, store: Store) -> ObjectBox.EntityId {
        let entity = entity as! BusRoute

        var offsets: [(offset: OBXDataOffset, index: UInt16)] = []
        offsets.append((propertyCollector.prepare(string: entity.lineName, at: 2 + 2 * 2), 2 + 2 * 2))
        offsets.append((propertyCollector.prepare(string: entity.destinationName, at: 2 + 2 * 3), 2 + 2 * 3))



        for value in offsets {
            propertyCollector.collect(dataOffset: value.offset, at: value.index)
        }

        return entity.id.value
    }

    func createEntity(entityReader: EntityReader, store: Store) -> Any {
        let entity = BusRoute()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.lineName = entityReader.read(at: 2 + 2 * 2)
        entity.destinationName = entityReader.read(at: 2 + 2 * 3)



        return entity
    }
}


fileprivate func modelBytes() -> Data {
    let modelBuilder = ModelBuilder()
    BusRoute.buildEntity(modelBuilder: modelBuilder)
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
    convenience init(directoryPath: String, maxDbSizeInKByte: UInt64 = 1024 * 1024, fileMode: UInt32 = 0o755, maxReaders: UInt32 = 0) throws {
        try self.init(
            modelBytes: modelBytes(),
            directory: directoryPath,
            maxDbSizeInKByte: maxDbSizeInKByte,
            fileMode: fileMode,
            maxReaders: maxReaders)
        registerAllEntities()
    }
    func registerAllEntities() {
        self.register(entity: BusRoute.self)
    }
}

// swiftlint:enable all

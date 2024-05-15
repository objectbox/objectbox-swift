// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata


extension WashingMachine: ObjectBox.__EntityRelatable {
    internal typealias EntityType = WashingMachine

    internal var _id: EntityId<WashingMachine> {
        return EntityId<WashingMachine>(self.id.value)
    }
}

extension WashingMachine: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = WashingMachineBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "WashingMachine", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: WashingMachine.self, id: 1, uid: 17664)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 14592)
        try entityBuilder.addProperty(name: "lineName", type: PropertyType.string, id: 2, uid: 16640)
        try entityBuilder.addProperty(name: "destinationName", type: PropertyType.string, id: 3, uid: 18688)

        try entityBuilder.lastProperty(id: 3, uid: 18688)
    }
}

extension WashingMachine {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { WashingMachine.id == myId }
    internal static var id: Property<WashingMachine, EntityId<WashingMachine>, EntityId<WashingMachine>> { return Property<WashingMachine, EntityId<WashingMachine>, EntityId<WashingMachine>>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { WashingMachine.lineName.startsWith("X") }
    internal static var lineName: Property<WashingMachine, String, Void> { return Property<WashingMachine, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { WashingMachine.destinationName.startsWith("X") }
    internal static var destinationName: Property<WashingMachine, String, Void> { return Property<WashingMachine, String, Void>(propertyId: 3, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = EntityId(identifier)
    }
}

extension ObjectBox.Property where E == WashingMachine {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<WashingMachine, EntityId<WashingMachine>, EntityId<WashingMachine>> { return Property<WashingMachine, EntityId<WashingMachine>, EntityId<WashingMachine>>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .lineName.startsWith("X") }

    internal static var lineName: Property<WashingMachine, String, Void> { return Property<WashingMachine, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .destinationName.startsWith("X") }

    internal static var destinationName: Property<WashingMachine, String, Void> { return Property<WashingMachine, String, Void>(propertyId: 3, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `WashingMachine.EntityBindingType`.
internal class WashingMachineBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = WashingMachine
    internal typealias IdType = EntityId<WashingMachine>

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
        let propertyOffset_lineName = propertyCollector.prepare(string: entity.lineName)
        let propertyOffset_destinationName = propertyCollector.prepare(string: entity.destinationName)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_lineName, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_destinationName, at: 2 + 2 * 3)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = WashingMachine()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.lineName = entityReader.read(at: 2 + 2 * 2)
        entity.destinationName = entityReader.read(at: 2 + 2 * 3)

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
    try WashingMachine.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 1, uid: 17664)
    modelBuilder.lastIndex(id: 1, uid: 15616)
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

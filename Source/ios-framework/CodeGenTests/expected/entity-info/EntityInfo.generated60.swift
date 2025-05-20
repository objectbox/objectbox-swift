// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata

extension Example: ObjectBox.Entity {}

extension Example: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Example

    internal var _id: EntityId<Example> {
        return EntityId<Example>(self.id.value)
    }
}

extension Example: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = ExampleBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Example", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Example.self, id: 1, uid: 18688)
        try entityBuilder.externalName("my-example-entity")
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 14592)
        try entityBuilder.addProperty(name: "myMongoId", type: PropertyType.long, id: 4, uid: 17664)
            .externalType(123)
        try entityBuilder.addProperty(name: "myJson", type: PropertyType.string, id: 5, uid: 19712)
            .externalType(109)
            .externalName("my-json")
        try entityBuilder.addToManyRelation(id: 1, uid: 17664,
                                            targetId: 1, targetUid: 18688)
        try entityBuilder.relationExternalType(102)
        try entityBuilder.relationExternalName("my-other-entities")

        try entityBuilder.lastProperty(id: 5, uid: 19712)
    }
}

extension Example {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Example.id == myId }
    internal static var id: Property<Example, Id, Id> { return Property<Example, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Example.myMongoId > 1234 }
    internal static var myMongoId: Property<Example, Int?, Void> { return Property<Example, Int?, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Example.myJson.startsWith("X") }
    internal static var myJson: Property<Example, String?, Void> { return Property<Example, String?, Void>(propertyId: 5, isPrimaryKey: false) }
    /// Use `Example.otherExamples` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var otherExamples: ToManyProperty<Example> { return ToManyProperty(.relationId(1)) }


    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Example {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Example, Id, Id> { return Property<Example, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .myMongoId > 1234 }

    internal static var myMongoId: Property<Example, Int?, Void> { return Property<Example, Int?, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .myJson.startsWith("X") }

    internal static var myJson: Property<Example, String?, Void> { return Property<Example, String?, Void>(propertyId: 5, isPrimaryKey: false) }

    /// Use `.otherExamples` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var otherExamples: ToManyProperty<Example> { return ToManyProperty(.relationId(1)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Example.EntityBindingType`.
internal class ExampleBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = Example
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
        let propertyOffset_myJson = propertyCollector.prepare(string: entity.myJson)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.myMongoId, at: 2 + 2 * 4)
        propertyCollector.collect(dataOffset: propertyOffset_myJson, at: 2 + 2 * 5)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) throws {
        if entityId(of: entity) == 0 {  // New object was put? Attach relations now that we have an ID.
            let otherExamples = ToMany<Example>.relation(
                sourceId: EntityId<Example>(id.value),
                targetBox: store.box(for: ToMany<Example>.ReferencedType.self),
                relationId: 1)
            if !entity.otherExamples.isEmpty {
                otherExamples.replace(entity.otherExamples)
            }
            entity.otherExamples = otherExamples
            try entity.otherExamples.applyToDb()
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Example()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.myMongoId = entityReader.read(at: 2 + 2 * 4)
        entity.myJson = entityReader.read(at: 2 + 2 * 5)

        entity.otherExamples = ToMany<Example>.relation(
            sourceId: EntityId<Example>(entity.id.value),
            targetBox: store.box(for: ToMany<Example>.ReferencedType.self),
            relationId: 1)
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
    try Example.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 1, uid: 18688)
    modelBuilder.lastRelation(id: 1, uid: 17664)
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

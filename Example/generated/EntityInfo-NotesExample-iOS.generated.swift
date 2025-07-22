// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata

extension Author: ObjectBox.Entity {}

extension Author: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Author

    internal var _id: EntityId<Author> {
        return EntityId<Author>(self.id.value)
    }
}

extension Author: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = AuthorBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static let entityInfo = ObjectBox.EntityInfo(name: "Author", id: 1)

    internal static let entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Author.self, id: 1, uid: 712683617673955584)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 6336800942024279296)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 5025387500910526208)

        try entityBuilder.lastProperty(id: 2, uid: 5025387500910526208)
    }
}

extension Author {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Author.id == myId }
    internal static var id: Property<Author, Id, Id> { return Property<Author, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Author.name.startsWith("X") }
    internal static var name: Property<Author, String, Void> { return Property<Author, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Use `Author.notes` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var notes: ToManyProperty<Note> { return ToManyProperty(.valuePropertyId(6)) }


    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Author {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Author, Id, Id> { return Property<Author, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<Author, String, Void> { return Property<Author, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Use `.notes` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var notes: ToManyProperty<Note> { return ToManyProperty(.valuePropertyId(6)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Author.EntityBindingType`.
internal final class AuthorBinding: ObjectBox.EntityBinding, Sendable {
    internal typealias EntityType = Author
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
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 2)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) throws {
        if entityId(of: entity) == 0 {  // New object was put? Attach relations now that we have an ID.
            let notes = ToMany<Note>.backlink(
                sourceBox: store.box(for: ToMany<Note>.ReferencedType.self),
                sourceProperty: ToMany<Note>.ReferencedType.author,
                targetId: EntityId<Author>(id.value))
            if !entity.notes.isEmpty {
                notes.replace(entity.notes)
            }
            entity.notes = notes
            try entity.notes.applyToDb()
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Author()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)

        entity.notes = ToMany<Note>.backlink(
            sourceBox: store.box(for: ToMany<Note>.ReferencedType.self),
            sourceProperty: ToMany<Note>.ReferencedType.author,
            targetId: EntityId<Author>(entity.id.value))
        return entity
    }
}



extension Note: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Note

    internal var _id: EntityId<Note> {
        return EntityId<Note>(self.id.value)
    }
}

extension Note: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = NoteBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static let entityInfo = ObjectBox.EntityInfo(name: "Note", id: 2)

    internal static let entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Note.self, id: 2, uid: 5608901830082711040)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 7180411752564202752)
        try entityBuilder.addProperty(name: "title", type: PropertyType.string, id: 2, uid: 249105953415333376)
        try entityBuilder.addProperty(name: "text", type: PropertyType.string, id: 3, uid: 5661281725891017216)
        try entityBuilder.addProperty(name: "creationDate", type: PropertyType.date, id: 4, uid: 8342334437465755392)
        try entityBuilder.addProperty(name: "modificationDate", type: PropertyType.date, id: 5, uid: 8881960381068888832)
        try entityBuilder.addToOneRelation(name: "author", targetEntityInfo: ToOne<Author>.Target.entityInfo, flags: [.indexed, .indexPartialSkipZero], id: 6, uid: 6001769173142034944, indexId: 1, indexUid: 6069708401898380544)

        try entityBuilder.lastProperty(id: 6, uid: 6001769173142034944)
    }
}

extension Note {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.id == myId }
    internal static var id: Property<Note, Id, Id> { return Property<Note, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.title.startsWith("X") }
    internal static var title: Property<Note, String, Void> { return Property<Note, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.text.startsWith("X") }
    internal static var text: Property<Note, String, Void> { return Property<Note, String, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.creationDate > 1234 }
    internal static var creationDate: Property<Note, Date?, Void> { return Property<Note, Date?, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.modificationDate > 1234 }
    internal static var modificationDate: Property<Note, Date?, Void> { return Property<Note, Date?, Void>(propertyId: 5, isPrimaryKey: false) }
    internal static var author: Property<Note, EntityId<ToOne<Author>.Target>, ToOne<Author>.Target> { return Property(propertyId: 6) }


    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Note {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Note, Id, Id> { return Property<Note, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .title.startsWith("X") }

    internal static var title: Property<Note, String, Void> { return Property<Note, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .text.startsWith("X") }

    internal static var text: Property<Note, String, Void> { return Property<Note, String, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .creationDate > 1234 }

    internal static var creationDate: Property<Note, Date?, Void> { return Property<Note, Date?, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .modificationDate > 1234 }

    internal static var modificationDate: Property<Note, Date?, Void> { return Property<Note, Date?, Void>(propertyId: 5, isPrimaryKey: false) }

    internal static var author: Property<Note, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target> { return Property<Note, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target>(propertyId: 6) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Note.EntityBindingType`.
internal final class NoteBinding: ObjectBox.EntityBinding, Sendable {
    internal typealias EntityType = Note
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
        let propertyOffset_title = propertyCollector.prepare(string: entity.title)
        let propertyOffset_text = propertyCollector.prepare(string: entity.text)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.creationDate, at: 2 + 2 * 4)
        propertyCollector.collect(entity.modificationDate, at: 2 + 2 * 5)
        try propertyCollector.collect(entity.author, at: 2 + 2 * 6, store: store)
        propertyCollector.collect(dataOffset: propertyOffset_title, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_text, at: 2 + 2 * 3)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) throws {
        if entityId(of: entity) == 0 {  // New object was put? Attach relations now that we have an ID.
            entity.author.attach(to: store.box(for: Author.self))
        }
    }
    internal func setToOneRelation(_ propertyId: obx_schema_id, of entity: EntityType, to entityId: ObjectBox.Id?) {
        switch propertyId {
            case 6:
                entity.author.targetId = (entityId != nil) ? EntityId<Author>(entityId!) : nil
            default:
                fatalError("Attempt to change nonexistent ToOne relation with ID \(propertyId)")
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Note()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.title = entityReader.read(at: 2 + 2 * 2)
        entity.text = entityReader.read(at: 2 + 2 * 3)
        entity.creationDate = entityReader.read(at: 2 + 2 * 4)
        entity.modificationDate = entityReader.read(at: 2 + 2 * 5)

        entity.author = entityReader.read(at: 2 + 2 * 6, store: store)
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
    try Author.buildEntity(modelBuilder: modelBuilder)
    try Note.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 2, uid: 5608901830082711040)
    modelBuilder.lastIndex(id: 1, uid: 6069708401898380544)
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

// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata


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
        let entityBuilder = try modelBuilder.entityBuilder(for: Author.self, id: 1, uid: 16640)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 14592)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 15616)

        try entityBuilder.lastProperty(id: 2, uid: 15616)
    }
}

extension Author {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Author.id == myId }
    internal static var id: Property<Author, EntityId<Author>, EntityId<Author>> { return Property<Author, EntityId<Author>, EntityId<Author>>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Author.name.startsWith("X") }
    internal static var name: Property<Author, String, Void> { return Property<Author, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Use `Author.books` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var books: ToManyProperty<Book> { return ToManyProperty(.valuePropertyId(3)) }


    fileprivate mutating func __setId(identifier: ObjectBox.Id) {
        self.id = EntityId(identifier)
    }
}

extension ObjectBox.Property where E == Author {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Author, EntityId<Author>, EntityId<Author>> { return Property<Author, EntityId<Author>, EntityId<Author>>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<Author, String, Void> { return Property<Author, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Use `.books` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var books: ToManyProperty<Book> { return ToManyProperty(.valuePropertyId(3)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Author.EntityBindingType`.
internal final class AuthorBinding: ObjectBox.EntityBinding, Sendable {
    internal typealias EntityType = Author
    internal typealias IdType = EntityId<Author>

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setStructEntityId(of entity: inout EntityType, to entityId: ObjectBox.Id) {
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

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entityId: EntityId<Author> = entityReader.read(at: 2 + 2 * 1)
        let entity = Author(
            id: entityId, 
            name: entityReader.read(at: 2 + 2 * 2), 
            books: ToMany<Book>.backlink(
                            sourceBox: store.box(for: ToMany<Book>.ReferencedType.self),
                            sourceProperty: ToMany<Book>.ReferencedType.author,
                            targetId: EntityId<Author>(entityId.value))
        )
        return entity
    }
}

extension ObjectBox.Box where E == Author {

    /// Puts the Author in the box (aka persisting it) returning a copy with the ID updated to the ID it
    /// has been assigned.
    /// If you know the entity has already been persisted, you can use put() to avoid the cost of the copy.
    ///
    /// - Parameter entity: Object to persist.
    /// - Returns: The stored object. If `entity`'s id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(struct entity: Author) throws -> Author {
        let entityId: Author.EntityBindingType.IdType = try self.put(entity)

        return Author(
            id: entityId, 
            name: entity.name, 
            books: entity.books
        )
    }

    /// Puts the Authors in the box (aka persisting it) returning copies with their IDs updated to the
    /// IDs they've been assigned.
    /// If you know all entities have already been persisted, you can use put() to avoid the cost of the
    /// copies.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Returns: The stored objects. If any entity's id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(structs entities: [Author]) throws -> [Author] {
        let entityIds: [Author.EntityBindingType.IdType] = try self.putAndReturnIDs(entities)
        var newEntities = [Author]()
        newEntities.reserveCapacity(entities.count)

        for i in 0 ..< min(entities.count, entityIds.count) {
            let entity = entities[i]
            let entityId = entityIds[i]

            newEntities.append(Author(
                id: entityId, 
                name: entity.name, 
                books: entity.books
            ))
        }

        return newEntities
    }
}


extension Book: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Book

    internal var _id: EntityId<Book> {
        return EntityId<Book>(self.id.value)
    }
}

extension Book: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = BookBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static let entityInfo = ObjectBox.EntityInfo(name: "Book", id: 2)

    internal static let entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Book.self, id: 2, uid: 21504)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 17664)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 18688)
        try entityBuilder.addToOneRelation(name: "author", targetEntityInfo: ToOne<Author>.Target.entityInfo, flags: [.indexed, .indexPartialSkipZero], id: 3, uid: 20736, indexId: 1, indexUid: 19712)

        try entityBuilder.lastProperty(id: 3, uid: 20736)
    }
}

extension Book {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Book.id == myId }
    internal static var id: Property<Book, EntityId<Book>, EntityId<Book>> { return Property<Book, EntityId<Book>, EntityId<Book>>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Book.name.startsWith("X") }
    internal static var name: Property<Book, String, Void> { return Property<Book, String, Void>(propertyId: 2, isPrimaryKey: false) }
    internal static var author: Property<Book, EntityId<ToOne<Author>.Target>, ToOne<Author>.Target> { return Property(propertyId: 3) }


    fileprivate mutating func __setId(identifier: ObjectBox.Id) {
        self.id = EntityId(identifier)
    }
}

extension ObjectBox.Property where E == Book {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Book, EntityId<Book>, EntityId<Book>> { return Property<Book, EntityId<Book>, EntityId<Book>>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<Book, String, Void> { return Property<Book, String, Void>(propertyId: 2, isPrimaryKey: false) }

    internal static var author: Property<Book, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target> { return Property<Book, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target>(propertyId: 3) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Book.EntityBindingType`.
internal final class BookBinding: ObjectBox.EntityBinding, Sendable {
    internal typealias EntityType = Book
    internal typealias IdType = EntityId<Book>

    internal required init() {}

    internal func generatorBindingVersion() -> Int { 1 }

    internal func setStructEntityId(of entity: inout EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) throws {
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        try propertyCollector.collect(entity.author, at: 2 + 2 * 3, store: store)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 2)
    }

    internal func setToOneRelation(_ propertyId: obx_schema_id, of entity: EntityType, to entityId: ObjectBox.Id?) {
        switch propertyId {
            case 3:
                entity.author.targetId = (entityId != nil) ? EntityId<Author>(entityId!) : nil
            default:
                fatalError("Attempt to change nonexistent ToOne relation with ID \(propertyId)")
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entityId: EntityId<Book> = entityReader.read(at: 2 + 2 * 1)
        let entity = Book(
            id: entityId, 
            name: entityReader.read(at: 2 + 2 * 2), 
            author: entityReader.read(at: 2 + 2 * 3, store: store)
        )
        return entity
    }
}

extension ObjectBox.Box where E == Book {

    /// Puts the Book in the box (aka persisting it) returning a copy with the ID updated to the ID it
    /// has been assigned.
    /// If you know the entity has already been persisted, you can use put() to avoid the cost of the copy.
    ///
    /// - Parameter entity: Object to persist.
    /// - Returns: The stored object. If `entity`'s id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(struct entity: Book) throws -> Book {
        let entityId: Book.EntityBindingType.IdType = try self.put(entity)

        return Book(
            id: entityId, 
            name: entity.name, 
            author: entity.author
        )
    }

    /// Puts the Books in the box (aka persisting it) returning copies with their IDs updated to the
    /// IDs they've been assigned.
    /// If you know all entities have already been persisted, you can use put() to avoid the cost of the
    /// copies.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Returns: The stored objects. If any entity's id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(structs entities: [Book]) throws -> [Book] {
        let entityIds: [Book.EntityBindingType.IdType] = try self.putAndReturnIDs(entities)
        var newEntities = [Book]()
        newEntities.reserveCapacity(entities.count)

        for i in 0 ..< min(entities.count, entityIds.count) {
            let entity = entities[i]
            let entityId = entityIds[i]

            newEntities.append(Book(
                id: entityId, 
                name: entity.name, 
                author: entity.author
            ))
        }

        return newEntities
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
    try Book.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 2, uid: 21504)
    modelBuilder.lastIndex(id: 1, uid: 19712)
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

// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox

// MARK: - Entity metadata


extension Author: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Author

    internal var _id: Id<Author> {
        return self.id
    }
}

extension Author: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = AuthorBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Author", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Author.self, id: 1, uid: 17664)
        try entityBuilder.addProperty(name: "id", type: Id<Author>.entityPropertyType, flags: [.id], id: 1, uid: 14592)
        try entityBuilder.addProperty(name: "name", type: String.entityPropertyType, id: 2, uid: 15616)
        // books
        try entityBuilder.addToManyRelation(id: 1, uid: 16640,
                                            targetId: 2, targetUid: 21504)

        try entityBuilder.lastProperty(id: 2, uid: 15616)
    }
}

extension Author {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Author.id == myId }
    internal static var id: Property<Author, Id<Author>> { return Property<Author, Id<Author>>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Author.name.startsWith("X") }
    internal static var name: Property<Author, String> { return Property<Author, String>(propertyId: 2, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.EntityId) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Author {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    static var id: Property<Author, Id<Author>> { return Property<Author, Id<Author>>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    static var name: Property<Author, String> { return Property<Author, String>(propertyId: 2, isPrimaryKey: false) }


}


/// Generated service type to handle persisting and reading entity data. Exposed through `Author.EntityBindingType`.
internal class AuthorBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = Author

    override internal required init() {}

    internal func setEntityId(of entity: EntityType, to entityId: ObjectBox.EntityId) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.EntityId {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: EntityId, propertyCollector: PropertyCollector, store: Store) {

        var offsets: [(offset: OBXDataOffset, index: UInt16)] = []
        offsets.append((propertyCollector.prepare(string: entity.name, at: 2 + 2 * 2), 2 + 2 * 2))

        propertyCollector.collect(id, at: 2 + 2 * 1)


        for value in offsets {
            propertyCollector.collect(dataOffset: value.offset, at: value.index)
        }
    }

    internal func postPut(fromEntity entity: EntityType, id: EntityId, store: Store) {
        if entityId(of: entity) == 0 { // Written for first time? Attach ToMany relations:
            print("postPut needs to write")
            let books = ToMany<Book, Author>.relation(
                sourceBox: store.box(for: ToMany<Book, Author>.OwningType.self),
                sourceId: Id<ToMany<Book, Author>.OwningType>(id),
                targetBox: store.box(for: ToMany<Book, Author>.ReferencedType.self),
                relationId: 1)
            books.replaceSubrange(books.startIndex ..< books.endIndex, with: entity.books)
            entity.books = books
        }
    }

    internal func createEntity(entityReader: EntityReader, store: Store) -> EntityType {
        let entity = Author()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)

        entity.books = ToMany<Book, Author>.relation(
            sourceBox: store.box(for: ToMany<Book, Author>.OwningType.self),
            sourceId: entity.id,
            targetBox: store.box(for: ToMany<Book, Author>.ReferencedType.self),
            relationId: 1)
        return entity
    }
}



extension Book: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Book

    internal var _id: Id<Book> {
        return self.id
    }
}

extension Book: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = BookBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Book", id: 2)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Book.self, id: 2, uid: 21504)
        try entityBuilder.addProperty(name: "id", type: Id<Book>.entityPropertyType, flags: [.id], id: 1, uid: 18688)
        try entityBuilder.addProperty(name: "name", type: String.entityPropertyType, id: 2, uid: 19712)
        // authors
        try entityBuilder.addToManyRelation(id: 2, uid: 20736,
                                            targetId: 1, targetUid: 17664)

        try entityBuilder.lastProperty(id: 2, uid: 19712)
    }
}

extension Book {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Book.id == myId }
    internal static var id: Property<Book, Id<Book>> { return Property<Book, Id<Book>>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Book.name.startsWith("X") }
    internal static var name: Property<Book, String> { return Property<Book, String>(propertyId: 2, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.EntityId) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Book {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    static var id: Property<Book, Id<Book>> { return Property<Book, Id<Book>>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    static var name: Property<Book, String> { return Property<Book, String>(propertyId: 2, isPrimaryKey: false) }


}


/// Generated service type to handle persisting and reading entity data. Exposed through `Book.EntityBindingType`.
internal class BookBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = Book

    override internal required init() {}

    internal func setEntityId(of entity: EntityType, to entityId: ObjectBox.EntityId) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.EntityId {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: EntityId, propertyCollector: PropertyCollector, store: Store) {

        var offsets: [(offset: OBXDataOffset, index: UInt16)] = []
        offsets.append((propertyCollector.prepare(string: entity.name, at: 2 + 2 * 2), 2 + 2 * 2))

        propertyCollector.collect(id, at: 2 + 2 * 1)


        for value in offsets {
            propertyCollector.collect(dataOffset: value.offset, at: value.index)
        }
    }

    internal func postPut(fromEntity entity: EntityType, id: EntityId, store: Store) {
        if entityId(of: entity) == 0 { // Written for first time? Attach ToMany relations:
            print("postPut needs to write")
            let authors = ToMany<Author, Book>.relation(
                sourceBox: store.box(for: ToMany<Author, Book>.OwningType.self),
                sourceId: Id<ToMany<Author, Book>.OwningType>(id),
                targetBox: store.box(for: ToMany<Author, Book>.ReferencedType.self),
                relationId: 2)
            authors.replaceSubrange(authors.startIndex ..< authors.endIndex, with: entity.authors)
            entity.authors = authors
        }
    }

    internal func createEntity(entityReader: EntityReader, store: Store) -> EntityType {
        let entity = Book()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)

        entity.authors = ToMany<Author, Book>.relation(
            sourceBox: store.box(for: ToMany<Author, Book>.OwningType.self),
            sourceId: entity.id,
            targetBox: store.box(for: ToMany<Author, Book>.ReferencedType.self),
            relationId: 2)
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
    let modelBuilder = try ModelBuilder()
    try Author.buildEntity(modelBuilder: modelBuilder)
    try Book.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 2, uid: 21504)
    modelBuilder.lastRelation(id: 2, uid: 20736)
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

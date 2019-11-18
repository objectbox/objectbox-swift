// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT

// swiftlint:disable all
import ObjectBox

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
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Author", id: 1)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Author.self, id: 1, uid: 16640)
        try entityBuilder.addProperty(name: "id", type: EntityId<Author>.entityPropertyType, flags: [.id], id: 1, uid: 14592)
        try entityBuilder.addProperty(name: "name", type: String.entityPropertyType, id: 2, uid: 15616)

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


    fileprivate func __setId(identifier: ObjectBox.Id) {
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
internal class AuthorBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = Author
    internal typealias IdType = EntityId<Author>

    override internal required init() {}

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) {
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 2)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) {
        if entityId(of: entity) == 0 { // Written for first time? Attach ToMany relations:
            let books = ToMany<Book>.backlink(
                sourceBox: store.box(for: ToMany<Book>.ReferencedType.self),
                sourceProperty: ToMany<Book>.ReferencedType.author,
                targetId: EntityId<Author>(id.value))
            if !entity.books.isEmpty {
                books.replace(entity.books)
            }
            entity.books = books
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Author()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)

        entity.books = ToMany<Book>.backlink(
            sourceBox: store.box(for: ToMany<Book>.ReferencedType.self),
            sourceProperty: ToMany<Book>.ReferencedType.author,
            targetId: EntityId<Author>(entity.id.value))
        return entity
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
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Book", id: 2)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Book.self, id: 2, uid: 21504)
        try entityBuilder.addProperty(name: "id", type: EntityId<Book>.entityPropertyType, flags: [.id], id: 1, uid: 17664)
        try entityBuilder.addProperty(name: "name", type: String.entityPropertyType, id: 2, uid: 18688)
        try entityBuilder.addToOneRelation(name: "author", targetEntityInfo: ToOne<Author>.Target.entityInfo, id: 3, uid: 20736, indexId: 1, indexUid: 19712)

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


    fileprivate func __setId(identifier: ObjectBox.Id) {
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
internal class BookBinding: NSObject, ObjectBox.EntityBinding {
    internal typealias EntityType = Book
    internal typealias IdType = EntityId<Book>

    override internal required init() {}

    internal func setEntityIdUnlessStruct(of entity: EntityType, to entityId: ObjectBox.Id) {
        entity.__setId(identifier: entityId)
    }

    internal func entityId(of entity: EntityType) -> ObjectBox.Id {
        return entity.id.value
    }

    internal func collect(fromEntity entity: EntityType, id: ObjectBox.Id,
                                  propertyCollector: ObjectBox.FlatBufferBuilder, store: ObjectBox.Store) {
        let propertyOffset_name = propertyCollector.prepare(string: entity.name)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.author, at: 2 + 2 * 3, store: store)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 2)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) {
        if entityId(of: entity) == 0 { // Written for first time? Attach ToMany relations:
            entity.author.attach(to: store.box(for: Author.self))
        }
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
        let entity = Book()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)

        entity.author = entityReader.read(at: 2 + 2 * 3, store: store)
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
    try Book.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 2, uid: 21504)
    modelBuilder.lastIndex(id: 1, uid: 19712)
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

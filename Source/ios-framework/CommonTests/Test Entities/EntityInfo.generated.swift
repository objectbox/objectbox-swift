// Generated using the ObjectBox Swift Generator — https://objectbox.io
// DO NOT EDIT
// swiftlint:disable all
import ObjectBox
import Foundation

// MARK: - Entity metadata

extension Author: ObjectBox.Entity {}
extension AuthorStruct: ObjectBox.Entity {}
extension NoteStruct: ObjectBox.Entity {}
extension Student: ObjectBox.Entity {}
extension Teacher: ObjectBox.Entity {}
extension UniqueEntity: ObjectBox.Entity {}

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
        let entityBuilder = try modelBuilder.entityBuilder(for: Author.self, id: 1, uid: 3576167000524145664)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 4782546707843525376)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 8205028904652262144)
        try entityBuilder.addProperty(name: "yearOfBirth", type: PropertyType.short, id: 3, uid: 6604692165263705088)
        try entityBuilder.addToManyRelation(id: 1, uid: 6166183021412625664,
                                            targetId: 3, targetUid: 8286413937822989568)

        try entityBuilder.lastProperty(id: 3, uid: 6604692165263705088)
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
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Author.yearOfBirth > 1234 }
    internal static var yearOfBirth: Property<Author, UInt16?, Void> { return Property<Author, UInt16?, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Use `Author.notesStandalone` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var notesStandalone: ToManyProperty<Note> { return ToManyProperty(.relationId(1)) }

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

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .yearOfBirth > 1234 }

    internal static var yearOfBirth: Property<Author, UInt16?, Void> { return Property<Author, UInt16?, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Use `.notesStandalone` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var notesStandalone: ToManyProperty<Note> { return ToManyProperty(.relationId(1)) }

    /// Use `.notes` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var notes: ToManyProperty<Note> { return ToManyProperty(.valuePropertyId(6)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Author.EntityBindingType`.
internal class AuthorBinding: ObjectBox.EntityBinding {
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
        propertyCollector.collect(entity.yearOfBirth, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 2)
    }

    internal func postPut(fromEntity entity: EntityType, id: ObjectBox.Id, store: ObjectBox.Store) throws {
        if entityId(of: entity) == 0 {  // New object was put? Attach relations now that we have an ID.
            let notesStandalone = ToMany<Note>.relation(
                sourceId: EntityId<Author>(id.value),
                targetBox: store.box(for: ToMany<Note>.ReferencedType.self),
                relationId: 1)
            if !entity.notesStandalone.isEmpty {
                notesStandalone.replace(entity.notesStandalone)
            }
            entity.notesStandalone = notesStandalone
            let notes = ToMany<Note>.backlink(
                sourceBox: store.box(for: ToMany<Note>.ReferencedType.self),
                sourceProperty: ToMany<Note>.ReferencedType.author,
                targetId: EntityId<Author>(id.value))
            if !entity.notes.isEmpty {
                notes.replace(entity.notes)
            }
            entity.notes = notes
            try entity.notesStandalone.applyToDb()
            try entity.notes.applyToDb()
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Author()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)
        entity.yearOfBirth = entityReader.read(at: 2 + 2 * 3)

        entity.notesStandalone = ToMany<Note>.relation(
            sourceId: EntityId<Author>(entity.id.value),
            targetBox: store.box(for: ToMany<Note>.ReferencedType.self),
            relationId: 1)
        entity.notes = ToMany<Note>.backlink(
            sourceBox: store.box(for: ToMany<Note>.ReferencedType.self),
            sourceProperty: ToMany<Note>.ReferencedType.author,
            targetId: EntityId<Author>(entity.id.value))
        return entity
    }
}



extension AuthorStruct: ObjectBox.__EntityRelatable {
    internal typealias EntityType = AuthorStruct

    internal var _id: EntityId<AuthorStruct> {
        return EntityId<AuthorStruct>(self.id.value)
    }
}

extension AuthorStruct: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = AuthorStructBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "AuthorStruct", id: 2)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: AuthorStruct.self, id: 2, uid: 1229901451922443520)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 3324125320646150656)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 2629753880188920064)
        try entityBuilder.addToManyRelation(id: 2, uid: 7420642801495878912,
                                            targetId: 4, targetUid: 1267197271366405632)

        try entityBuilder.lastProperty(id: 2, uid: 2629753880188920064)
    }
}

extension AuthorStruct {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { AuthorStruct.id == myId }
    internal static var id: Property<AuthorStruct, Id, Id> { return Property<AuthorStruct, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { AuthorStruct.name.startsWith("X") }
    internal static var name: Property<AuthorStruct, String, Void> { return Property<AuthorStruct, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Use `AuthorStruct.notes` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var notes: ToManyProperty<NoteStruct> { return ToManyProperty(.relationId(2)) }


    fileprivate mutating func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == AuthorStruct {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<AuthorStruct, Id, Id> { return Property<AuthorStruct, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<AuthorStruct, String, Void> { return Property<AuthorStruct, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Use `.notes` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var notes: ToManyProperty<NoteStruct> { return ToManyProperty(.relationId(2)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `AuthorStruct.EntityBindingType`.
internal class AuthorStructBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = AuthorStruct
    internal typealias IdType = Id

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
        let entityId: Id = entityReader.read(at: 2 + 2 * 1)
        let entity = AuthorStruct(
            id: entityId, 
            name: entityReader.read(at: 2 + 2 * 2), 
            notes: ToMany<NoteStruct>.relation(
                            sourceId: EntityId<AuthorStruct>(entityId.value),
                            targetBox: store.box(for: ToMany<NoteStruct>.ReferencedType.self),
                            relationId: 2)
        )
        return entity
    }
}

extension ObjectBox.Box where E == AuthorStruct {

    /// Puts the AuthorStruct in the box (aka persisting it) returning a copy with the ID updated to the ID it
    /// has been assigned.
    /// If you know the entity has already been persisted, you can use put() to avoid the cost of the copy.
    ///
    /// - Parameter entity: Object to persist.
    /// - Returns: The stored object. If `entity`'s id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(struct entity: AuthorStruct) throws -> AuthorStruct {
        let entityId: AuthorStruct.EntityBindingType.IdType = try self.put(entity)

        return AuthorStruct(
            id: entityId, 
            name: entity.name, 
            notes: entity.notes
        )
    }

    /// Puts the AuthorStructs in the box (aka persisting it) returning copies with their IDs updated to the
    /// IDs they've been assigned.
    /// If you know all entities have already been persisted, you can use put() to avoid the cost of the
    /// copies.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Returns: The stored objects. If any entity's id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(structs entities: [AuthorStruct]) throws -> [AuthorStruct] {
        let entityIds: [AuthorStruct.EntityBindingType.IdType] = try self.putAndReturnIDs(entities)
        var newEntities = [AuthorStruct]()
        newEntities.reserveCapacity(entities.count)

        for i in 0 ..< min(entities.count, entityIds.count) {
            let entity = entities[i]
            let entityId = entityIds[i]

            newEntities.append(AuthorStruct(
                id: entityId, 
                name: entity.name, 
                notes: entity.notes
            ))
        }

        return newEntities
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
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Note", id: 3)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Note.self, id: 3, uid: 8286413937822989568)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 8202191337322996480)
        try entityBuilder.addProperty(name: "title", type: PropertyType.string, id: 2, uid: 1350315346983447296)
        try entityBuilder.addProperty(name: "text", type: PropertyType.string, id: 3, uid: 2156716490547525120)
        try entityBuilder.addProperty(name: "creationDate", type: PropertyType.date, id: 4, uid: 2259363133844796672)
        try entityBuilder.addProperty(name: "modificationDate", type: PropertyType.date, id: 5, uid: 6233774800911586048)
        try entityBuilder.addProperty(name: "done", type: PropertyType.bool, id: 7, uid: 3390351202128481792)
        try entityBuilder.addProperty(name: "upvotes", type: PropertyType.int, flags: [.unsigned], id: 8, uid: 5856576790296241408)
        try entityBuilder.addToOneRelation(name: "author", targetEntityInfo: ToOne<Author>.Target.entityInfo, flags: [.indexed, .indexPartialSkipZero], id: 6, uid: 6448513910062322432, indexId: 1, indexUid: 1458654215934992896)

        try entityBuilder.lastProperty(id: 8, uid: 5856576790296241408)
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
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.done == true }
    internal static var done: Property<Note, Bool, Void> { return Property<Note, Bool, Void>(propertyId: 7, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Note.upvotes > 1234 }
    internal static var upvotes: Property<Note, UInt32, Void> { return Property<Note, UInt32, Void>(propertyId: 8, isPrimaryKey: false) }
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

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .done == true }

    internal static var done: Property<Note, Bool, Void> { return Property<Note, Bool, Void>(propertyId: 7, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .upvotes > 1234 }

    internal static var upvotes: Property<Note, UInt32, Void> { return Property<Note, UInt32, Void>(propertyId: 8, isPrimaryKey: false) }

    internal static var author: Property<Note, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target> { return Property<Note, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target>(propertyId: 6) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Note.EntityBindingType`.
internal class NoteBinding: ObjectBox.EntityBinding {
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
        propertyCollector.collect(entity.done, at: 2 + 2 * 7)
        propertyCollector.collect(entity.upvotes, at: 2 + 2 * 8)
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
        entity.done = entityReader.read(at: 2 + 2 * 7)
        entity.upvotes = entityReader.read(at: 2 + 2 * 8)

        entity.author = entityReader.read(at: 2 + 2 * 6, store: store)
        return entity
    }
}



extension NoteStruct: ObjectBox.__EntityRelatable {
    internal typealias EntityType = NoteStruct

    internal var _id: EntityId<NoteStruct> {
        return EntityId<NoteStruct>(self.id.value)
    }
}

extension NoteStruct: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = NoteStructBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "NoteStruct", id: 4)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: NoteStruct.self, id: 4, uid: 1267197271366405632)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 2519416082326737408)
        try entityBuilder.addProperty(name: "title", type: PropertyType.string, id: 2, uid: 551839225092133376)
        try entityBuilder.addProperty(name: "text", type: PropertyType.string, id: 3, uid: 7011109989572489472)
        try entityBuilder.addProperty(name: "creationDate", type: PropertyType.date, id: 4, uid: 778896539487013376)
        try entityBuilder.addProperty(name: "modificationDate", type: PropertyType.date, id: 5, uid: 7303324335582009600)
        try entityBuilder.addToOneRelation(name: "author", targetEntityInfo: ToOne<Author>.Target.entityInfo, flags: [.indexed, .indexPartialSkipZero], id: 6, uid: 2469372667932281088, indexId: 2, indexUid: 6342353045634752256)

        try entityBuilder.lastProperty(id: 6, uid: 2469372667932281088)
    }
}

extension NoteStruct {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { NoteStruct.id == myId }
    internal static var id: Property<NoteStruct, Id, Id> { return Property<NoteStruct, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { NoteStruct.title.startsWith("X") }
    internal static var title: Property<NoteStruct, String, Void> { return Property<NoteStruct, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { NoteStruct.text.startsWith("X") }
    internal static var text: Property<NoteStruct, String, Void> { return Property<NoteStruct, String, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { NoteStruct.creationDate > 1234 }
    internal static var creationDate: Property<NoteStruct, Date?, Void> { return Property<NoteStruct, Date?, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { NoteStruct.modificationDate > 1234 }
    internal static var modificationDate: Property<NoteStruct, Date?, Void> { return Property<NoteStruct, Date?, Void>(propertyId: 5, isPrimaryKey: false) }
    internal static var author: Property<NoteStruct, EntityId<ToOne<Author>.Target>, ToOne<Author>.Target> { return Property(propertyId: 6) }


    fileprivate mutating func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == NoteStruct {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<NoteStruct, Id, Id> { return Property<NoteStruct, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .title.startsWith("X") }

    internal static var title: Property<NoteStruct, String, Void> { return Property<NoteStruct, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .text.startsWith("X") }

    internal static var text: Property<NoteStruct, String, Void> { return Property<NoteStruct, String, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .creationDate > 1234 }

    internal static var creationDate: Property<NoteStruct, Date?, Void> { return Property<NoteStruct, Date?, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .modificationDate > 1234 }

    internal static var modificationDate: Property<NoteStruct, Date?, Void> { return Property<NoteStruct, Date?, Void>(propertyId: 5, isPrimaryKey: false) }

    internal static var author: Property<NoteStruct, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target> { return Property<NoteStruct, ToOne<Author>.Target.EntityBindingType.IdType, ToOne<Author>.Target>(propertyId: 6) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `NoteStruct.EntityBindingType`.
internal class NoteStructBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = NoteStruct
    internal typealias IdType = Id

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
        let propertyOffset_title = propertyCollector.prepare(string: entity.title)
        let propertyOffset_text = propertyCollector.prepare(string: entity.text)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(entity.creationDate, at: 2 + 2 * 4)
        propertyCollector.collect(entity.modificationDate, at: 2 + 2 * 5)
        try propertyCollector.collect(entity.author, at: 2 + 2 * 6, store: store)
        propertyCollector.collect(dataOffset: propertyOffset_title, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_text, at: 2 + 2 * 3)
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
        let entityId: Id = entityReader.read(at: 2 + 2 * 1)
        let entity = NoteStruct(
            id: entityId, 
            title: entityReader.read(at: 2 + 2 * 2), 
            text: entityReader.read(at: 2 + 2 * 3), 
            creationDate: entityReader.read(at: 2 + 2 * 4), 
            modificationDate: entityReader.read(at: 2 + 2 * 5), 
            author: entityReader.read(at: 2 + 2 * 6, store: store)
        )
        return entity
    }
}

extension ObjectBox.Box where E == NoteStruct {

    /// Puts the NoteStruct in the box (aka persisting it) returning a copy with the ID updated to the ID it
    /// has been assigned.
    /// If you know the entity has already been persisted, you can use put() to avoid the cost of the copy.
    ///
    /// - Parameter entity: Object to persist.
    /// - Returns: The stored object. If `entity`'s id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(struct entity: NoteStruct) throws -> NoteStruct {
        let entityId: NoteStruct.EntityBindingType.IdType = try self.put(entity)

        return NoteStruct(
            id: entityId, 
            title: entity.title, 
            text: entity.text, 
            creationDate: entity.creationDate, 
            modificationDate: entity.modificationDate, 
            author: entity.author
        )
    }

    /// Puts the NoteStructs in the box (aka persisting it) returning copies with their IDs updated to the
    /// IDs they've been assigned.
    /// If you know all entities have already been persisted, you can use put() to avoid the cost of the
    /// copies.
    ///
    /// - Parameter entities: Objects to persist.
    /// - Returns: The stored objects. If any entity's id is 0, an ID is generated.
    /// - Throws: ObjectBoxError errors for database write errors.
    func put(structs entities: [NoteStruct]) throws -> [NoteStruct] {
        let entityIds: [NoteStruct.EntityBindingType.IdType] = try self.putAndReturnIDs(entities)
        var newEntities = [NoteStruct]()
        newEntities.reserveCapacity(entities.count)

        for i in 0 ..< min(entities.count, entityIds.count) {
            let entity = entities[i]
            let entityId = entityIds[i]

            newEntities.append(NoteStruct(
                id: entityId, 
                title: entity.title, 
                text: entity.text, 
                creationDate: entity.creationDate, 
                modificationDate: entity.modificationDate, 
                author: entity.author
            ))
        }

        return newEntities
    }
}


extension Student: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Student

    internal var _id: EntityId<Student> {
        return EntityId<Student>(self.id.value)
    }
}

extension Student: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = StudentBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Student", id: 5)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Student.self, id: 5, uid: 7762515417864690432)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 5805489249593327360)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 2830525844876407040)
        try entityBuilder.addToManyRelation(id: 3, uid: 417604695477796352,
                                            targetId: 6, targetUid: 4388202328849468160)

        try entityBuilder.lastProperty(id: 2, uid: 2830525844876407040)
    }
}

extension Student {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Student.id == myId }
    internal static var id: Property<Student, Id, Id> { return Property<Student, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Student.name.startsWith("X") }
    internal static var name: Property<Student, String, Void> { return Property<Student, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Use `Student.teachers` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var teachers: ToManyProperty<Teacher> { return ToManyProperty(.relationId(3)) }


    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Student {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Student, Id, Id> { return Property<Student, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<Student, String, Void> { return Property<Student, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Use `.teachers` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var teachers: ToManyProperty<Teacher> { return ToManyProperty(.relationId(3)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Student.EntityBindingType`.
internal class StudentBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = Student
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
            let teachers = ToMany<Teacher>.relation(
                sourceId: EntityId<Student>(id.value),
                targetBox: store.box(for: ToMany<Teacher>.ReferencedType.self),
                relationId: 3)
            if !entity.teachers.isEmpty {
                teachers.replace(entity.teachers)
            }
            entity.teachers = teachers
            try entity.teachers.applyToDb()
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Student()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)

        entity.teachers = ToMany<Teacher>.relation(
            sourceId: EntityId<Student>(entity.id.value),
            targetBox: store.box(for: ToMany<Teacher>.ReferencedType.self),
            relationId: 3)
        return entity
    }
}



extension Teacher: ObjectBox.__EntityRelatable {
    internal typealias EntityType = Teacher

    internal var _id: EntityId<Teacher> {
        return EntityId<Teacher>(self.id.value)
    }
}

extension Teacher: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = TeacherBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "Teacher", id: 6)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: Teacher.self, id: 6, uid: 4388202328849468160)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 2783284586616908288)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, id: 2, uid: 5715806910771247872)

        try entityBuilder.lastProperty(id: 2, uid: 5715806910771247872)
    }
}

extension Teacher {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Teacher.id == myId }
    internal static var id: Property<Teacher, Id, Id> { return Property<Teacher, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { Teacher.name.startsWith("X") }
    internal static var name: Property<Teacher, String, Void> { return Property<Teacher, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Use `Teacher.students` to refer to this ToMany relation property in queries,
    /// like when using `QueryBuilder.and(property:, conditions:)`.

    internal static var students: ToManyProperty<Student> { return ToManyProperty(.backlinkRelationId(3)) }


    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == Teacher {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<Teacher, Id, Id> { return Property<Teacher, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<Teacher, String, Void> { return Property<Teacher, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Use `.students` to refer to this ToMany relation property in queries, like when using
    /// `QueryBuilder.and(property:, conditions:)`.

    internal static var students: ToManyProperty<Student> { return ToManyProperty(.backlinkRelationId(3)) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `Teacher.EntityBindingType`.
internal class TeacherBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = Teacher
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
            let students = ToMany<Student>.backlink(
                sourceBox: store.box(for: ToMany<Student>.ReferencedType.self),
                targetId: EntityId<Teacher>(id.value),
                relationId: 3)
            if !entity.students.isEmpty {
                students.replace(entity.students)
            }
            entity.students = students
            try entity.students.applyToDb()
        }
    }
    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = Teacher()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)

        entity.students = ToMany<Student>.backlink(
            sourceBox: store.box(for: ToMany<Student>.ReferencedType.self),
            targetId: EntityId<Teacher>(entity.id.value),
            relationId: 3)
        return entity
    }
}



extension UniqueEntity: ObjectBox.__EntityRelatable {
    internal typealias EntityType = UniqueEntity

    internal var _id: EntityId<UniqueEntity> {
        return EntityId<UniqueEntity>(self.id.value)
    }
}

extension UniqueEntity: ObjectBox.EntityInspectable {
    internal typealias EntityBindingType = UniqueEntityBinding

    /// Generated metadata used by ObjectBox to persist the entity.
    internal static var entityInfo = ObjectBox.EntityInfo(name: "UniqueEntity", id: 7)

    internal static var entityBinding = EntityBindingType()

    fileprivate static func buildEntity(modelBuilder: ObjectBox.ModelBuilder) throws {
        let entityBuilder = try modelBuilder.entityBuilder(for: UniqueEntity.self, id: 7, uid: 6258744021471265280)
        try entityBuilder.addProperty(name: "id", type: PropertyType.long, flags: [.id], id: 1, uid: 8418474383607017216)
        try entityBuilder.addProperty(name: "name", type: PropertyType.string, flags: [.unique, .indexHash, .indexed], id: 2, uid: 6588651899515438336, indexId: 3, indexUid: 4943227758701996288)
        try entityBuilder.addProperty(name: "content", type: PropertyType.string, id: 3, uid: 2295067898156422912)
        try entityBuilder.addProperty(name: "content2", type: PropertyType.string, id: 4, uid: 8083811964173041920)
        try entityBuilder.addProperty(name: "str1", type: PropertyType.string, id: 5, uid: 2085921255424893696)
        try entityBuilder.addProperty(name: "str2", type: PropertyType.string, id: 6, uid: 3046539664613253632)
        try entityBuilder.addProperty(name: "str3", type: PropertyType.string, id: 7, uid: 4836319770403460352)
        try entityBuilder.addProperty(name: "str4", type: PropertyType.string, id: 8, uid: 5586670376507097344)
        try entityBuilder.addProperty(name: "str5", type: PropertyType.string, id: 9, uid: 8779305452755862528)
        try entityBuilder.addProperty(name: "str6", type: PropertyType.string, id: 10, uid: 7042629853749457152)
        try entityBuilder.addProperty(name: "str7", type: PropertyType.string, id: 11, uid: 439706265026898176)
        try entityBuilder.addProperty(name: "str8", type: PropertyType.string, id: 12, uid: 7797853325787760640)
        try entityBuilder.addProperty(name: "str9", type: PropertyType.string, id: 13, uid: 6241625149586299904)
        try entityBuilder.addProperty(name: "str10", type: PropertyType.string, id: 14, uid: 3838386263292640000)
        try entityBuilder.addProperty(name: "str11", type: PropertyType.string, id: 15, uid: 2743032249190027008)
        try entityBuilder.addProperty(name: "str12", type: PropertyType.string, id: 16, uid: 6199657977327115264)
        try entityBuilder.addProperty(name: "str13", type: PropertyType.string, id: 17, uid: 6070699861433961728)
        try entityBuilder.addProperty(name: "str14", type: PropertyType.string, id: 18, uid: 6029297771178376192)
        try entityBuilder.addProperty(name: "str15", type: PropertyType.string, id: 19, uid: 3801959474204611328)
        try entityBuilder.addProperty(name: "str16", type: PropertyType.string, id: 20, uid: 4774675437756918784)
        try entityBuilder.addProperty(name: "str17", type: PropertyType.string, id: 21, uid: 8716823039315984640)
        try entityBuilder.addProperty(name: "str18", type: PropertyType.string, id: 22, uid: 8894733078890829312)
        try entityBuilder.addProperty(name: "str19", type: PropertyType.string, id: 23, uid: 1016331229052728320)
        try entityBuilder.addProperty(name: "str20", type: PropertyType.string, id: 24, uid: 7810872262587479552)
        try entityBuilder.addProperty(name: "str21", type: PropertyType.string, id: 25, uid: 4945264553128454912)
        try entityBuilder.addProperty(name: "str22", type: PropertyType.string, id: 26, uid: 7152265273971458560)
        try entityBuilder.addProperty(name: "str23", type: PropertyType.string, id: 27, uid: 6294538152931964672)
        try entityBuilder.addProperty(name: "str24", type: PropertyType.string, id: 28, uid: 1939674925644995328)
        try entityBuilder.addProperty(name: "str25", type: PropertyType.string, id: 29, uid: 2630803146682539264)
        try entityBuilder.addProperty(name: "str26", type: PropertyType.string, id: 30, uid: 2158082104313626880)
        try entityBuilder.addProperty(name: "str27", type: PropertyType.string, id: 31, uid: 4342475978535002368)
        try entityBuilder.addProperty(name: "str28", type: PropertyType.string, id: 32, uid: 2618142912991854080)
        try entityBuilder.addProperty(name: "str29", type: PropertyType.string, id: 33, uid: 4257312550012133632)
        try entityBuilder.addProperty(name: "str30", type: PropertyType.string, id: 34, uid: 6658936396910379008)
        try entityBuilder.addProperty(name: "str31", type: PropertyType.string, id: 35, uid: 7163695098896884992)
        try entityBuilder.addProperty(name: "str32", type: PropertyType.string, id: 36, uid: 7792683921785881088)
        try entityBuilder.addProperty(name: "str33", type: PropertyType.string, id: 37, uid: 2422385911045001728)
        try entityBuilder.addProperty(name: "str34", type: PropertyType.string, id: 38, uid: 672123555343571712)
        try entityBuilder.addProperty(name: "str35", type: PropertyType.string, id: 39, uid: 3356171792266690304)
        try entityBuilder.addProperty(name: "str36", type: PropertyType.string, id: 40, uid: 8097607156277667584)
        try entityBuilder.addProperty(name: "str37", type: PropertyType.string, id: 41, uid: 5877691172915301888)
        try entityBuilder.addProperty(name: "str38", type: PropertyType.string, id: 42, uid: 7464585023102901248)
        try entityBuilder.addProperty(name: "str39", type: PropertyType.string, id: 43, uid: 8211367673094595840)
        try entityBuilder.addProperty(name: "str40", type: PropertyType.string, id: 44, uid: 123610260452597504)
        try entityBuilder.addProperty(name: "str41", type: PropertyType.string, id: 45, uid: 2650611557939850240)
        try entityBuilder.addProperty(name: "str42", type: PropertyType.string, id: 46, uid: 8393105718552925184)
        try entityBuilder.addProperty(name: "str43", type: PropertyType.string, id: 47, uid: 6619994367521497344)
        try entityBuilder.addProperty(name: "str44", type: PropertyType.string, id: 48, uid: 4805478268913715712)
        try entityBuilder.addProperty(name: "str45", type: PropertyType.string, id: 49, uid: 8642866290657149184)
        try entityBuilder.addProperty(name: "str46", type: PropertyType.string, id: 50, uid: 5061363131252470016)
        try entityBuilder.addProperty(name: "str47", type: PropertyType.string, id: 51, uid: 4113947004423223040)
        try entityBuilder.addProperty(name: "str48", type: PropertyType.string, id: 52, uid: 9141471831020050944)
        try entityBuilder.addProperty(name: "str49", type: PropertyType.string, id: 53, uid: 938475961386865664)
        try entityBuilder.addProperty(name: "str50", type: PropertyType.string, id: 54, uid: 2610097445773727232)
        try entityBuilder.addProperty(name: "str51", type: PropertyType.string, id: 55, uid: 8223075157327230976)
        try entityBuilder.addProperty(name: "str52", type: PropertyType.string, id: 56, uid: 6658701894057099520)
        try entityBuilder.addProperty(name: "str53", type: PropertyType.string, id: 57, uid: 4320563155554460672)
        try entityBuilder.addProperty(name: "str54", type: PropertyType.string, id: 58, uid: 3648783095476185088)
        try entityBuilder.addProperty(name: "str55", type: PropertyType.string, id: 59, uid: 7718378802309229824)
        try entityBuilder.addProperty(name: "str56", type: PropertyType.string, id: 60, uid: 7657786762797563392)
        try entityBuilder.addProperty(name: "str57", type: PropertyType.string, id: 61, uid: 729766303749804544)
        try entityBuilder.addProperty(name: "str58", type: PropertyType.string, id: 62, uid: 8250473843241116672)
        try entityBuilder.addProperty(name: "str59", type: PropertyType.string, id: 63, uid: 4473980843763389184)

        try entityBuilder.lastProperty(id: 63, uid: 4473980843763389184)
    }
}

extension UniqueEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.id == myId }
    internal static var id: Property<UniqueEntity, Id, Id> { return Property<UniqueEntity, Id, Id>(propertyId: 1, isPrimaryKey: true) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.name.startsWith("X") }
    internal static var name: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.content.startsWith("X") }
    internal static var content: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 3, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.content2.startsWith("X") }
    internal static var content2: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 4, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str1.startsWith("X") }
    internal static var str1: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 5, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str2.startsWith("X") }
    internal static var str2: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 6, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str3.startsWith("X") }
    internal static var str3: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 7, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str4.startsWith("X") }
    internal static var str4: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 8, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str5.startsWith("X") }
    internal static var str5: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 9, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str6.startsWith("X") }
    internal static var str6: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 10, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str7.startsWith("X") }
    internal static var str7: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 11, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str8.startsWith("X") }
    internal static var str8: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 12, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str9.startsWith("X") }
    internal static var str9: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 13, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str10.startsWith("X") }
    internal static var str10: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 14, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str11.startsWith("X") }
    internal static var str11: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 15, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str12.startsWith("X") }
    internal static var str12: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 16, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str13.startsWith("X") }
    internal static var str13: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 17, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str14.startsWith("X") }
    internal static var str14: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 18, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str15.startsWith("X") }
    internal static var str15: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 19, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str16.startsWith("X") }
    internal static var str16: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 20, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str17.startsWith("X") }
    internal static var str17: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 21, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str18.startsWith("X") }
    internal static var str18: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 22, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str19.startsWith("X") }
    internal static var str19: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 23, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str20.startsWith("X") }
    internal static var str20: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 24, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str21.startsWith("X") }
    internal static var str21: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 25, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str22.startsWith("X") }
    internal static var str22: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 26, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str23.startsWith("X") }
    internal static var str23: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 27, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str24.startsWith("X") }
    internal static var str24: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 28, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str25.startsWith("X") }
    internal static var str25: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 29, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str26.startsWith("X") }
    internal static var str26: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 30, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str27.startsWith("X") }
    internal static var str27: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 31, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str28.startsWith("X") }
    internal static var str28: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 32, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str29.startsWith("X") }
    internal static var str29: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 33, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str30.startsWith("X") }
    internal static var str30: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 34, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str31.startsWith("X") }
    internal static var str31: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 35, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str32.startsWith("X") }
    internal static var str32: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 36, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str33.startsWith("X") }
    internal static var str33: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 37, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str34.startsWith("X") }
    internal static var str34: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 38, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str35.startsWith("X") }
    internal static var str35: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 39, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str36.startsWith("X") }
    internal static var str36: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 40, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str37.startsWith("X") }
    internal static var str37: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 41, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str38.startsWith("X") }
    internal static var str38: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 42, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str39.startsWith("X") }
    internal static var str39: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 43, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str40.startsWith("X") }
    internal static var str40: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 44, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str41.startsWith("X") }
    internal static var str41: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 45, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str42.startsWith("X") }
    internal static var str42: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 46, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str43.startsWith("X") }
    internal static var str43: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 47, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str44.startsWith("X") }
    internal static var str44: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 48, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str45.startsWith("X") }
    internal static var str45: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 49, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str46.startsWith("X") }
    internal static var str46: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 50, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str47.startsWith("X") }
    internal static var str47: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 51, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str48.startsWith("X") }
    internal static var str48: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 52, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str49.startsWith("X") }
    internal static var str49: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 53, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str50.startsWith("X") }
    internal static var str50: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 54, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str51.startsWith("X") }
    internal static var str51: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 55, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str52.startsWith("X") }
    internal static var str52: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 56, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str53.startsWith("X") }
    internal static var str53: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 57, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str54.startsWith("X") }
    internal static var str54: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 58, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str55.startsWith("X") }
    internal static var str55: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 59, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str56.startsWith("X") }
    internal static var str56: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 60, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str57.startsWith("X") }
    internal static var str57: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 61, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str58.startsWith("X") }
    internal static var str58: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 62, isPrimaryKey: false) }
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { UniqueEntity.str59.startsWith("X") }
    internal static var str59: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 63, isPrimaryKey: false) }

    fileprivate func __setId(identifier: ObjectBox.Id) {
        self.id = Id(identifier)
    }
}

extension ObjectBox.Property where E == UniqueEntity {
    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .id == myId }

    internal static var id: Property<UniqueEntity, Id, Id> { return Property<UniqueEntity, Id, Id>(propertyId: 1, isPrimaryKey: true) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .name.startsWith("X") }

    internal static var name: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 2, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .content.startsWith("X") }

    internal static var content: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 3, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .content2.startsWith("X") }

    internal static var content2: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 4, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str1.startsWith("X") }

    internal static var str1: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 5, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str2.startsWith("X") }

    internal static var str2: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 6, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str3.startsWith("X") }

    internal static var str3: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 7, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str4.startsWith("X") }

    internal static var str4: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 8, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str5.startsWith("X") }

    internal static var str5: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 9, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str6.startsWith("X") }

    internal static var str6: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 10, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str7.startsWith("X") }

    internal static var str7: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 11, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str8.startsWith("X") }

    internal static var str8: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 12, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str9.startsWith("X") }

    internal static var str9: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 13, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str10.startsWith("X") }

    internal static var str10: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 14, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str11.startsWith("X") }

    internal static var str11: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 15, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str12.startsWith("X") }

    internal static var str12: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 16, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str13.startsWith("X") }

    internal static var str13: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 17, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str14.startsWith("X") }

    internal static var str14: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 18, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str15.startsWith("X") }

    internal static var str15: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 19, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str16.startsWith("X") }

    internal static var str16: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 20, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str17.startsWith("X") }

    internal static var str17: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 21, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str18.startsWith("X") }

    internal static var str18: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 22, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str19.startsWith("X") }

    internal static var str19: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 23, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str20.startsWith("X") }

    internal static var str20: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 24, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str21.startsWith("X") }

    internal static var str21: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 25, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str22.startsWith("X") }

    internal static var str22: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 26, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str23.startsWith("X") }

    internal static var str23: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 27, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str24.startsWith("X") }

    internal static var str24: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 28, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str25.startsWith("X") }

    internal static var str25: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 29, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str26.startsWith("X") }

    internal static var str26: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 30, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str27.startsWith("X") }

    internal static var str27: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 31, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str28.startsWith("X") }

    internal static var str28: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 32, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str29.startsWith("X") }

    internal static var str29: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 33, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str30.startsWith("X") }

    internal static var str30: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 34, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str31.startsWith("X") }

    internal static var str31: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 35, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str32.startsWith("X") }

    internal static var str32: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 36, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str33.startsWith("X") }

    internal static var str33: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 37, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str34.startsWith("X") }

    internal static var str34: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 38, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str35.startsWith("X") }

    internal static var str35: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 39, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str36.startsWith("X") }

    internal static var str36: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 40, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str37.startsWith("X") }

    internal static var str37: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 41, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str38.startsWith("X") }

    internal static var str38: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 42, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str39.startsWith("X") }

    internal static var str39: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 43, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str40.startsWith("X") }

    internal static var str40: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 44, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str41.startsWith("X") }

    internal static var str41: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 45, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str42.startsWith("X") }

    internal static var str42: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 46, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str43.startsWith("X") }

    internal static var str43: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 47, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str44.startsWith("X") }

    internal static var str44: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 48, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str45.startsWith("X") }

    internal static var str45: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 49, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str46.startsWith("X") }

    internal static var str46: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 50, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str47.startsWith("X") }

    internal static var str47: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 51, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str48.startsWith("X") }

    internal static var str48: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 52, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str49.startsWith("X") }

    internal static var str49: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 53, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str50.startsWith("X") }

    internal static var str50: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 54, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str51.startsWith("X") }

    internal static var str51: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 55, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str52.startsWith("X") }

    internal static var str52: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 56, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str53.startsWith("X") }

    internal static var str53: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 57, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str54.startsWith("X") }

    internal static var str54: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 58, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str55.startsWith("X") }

    internal static var str55: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 59, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str56.startsWith("X") }

    internal static var str56: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 60, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str57.startsWith("X") }

    internal static var str57: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 61, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str58.startsWith("X") }

    internal static var str58: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 62, isPrimaryKey: false) }

    /// Generated entity property information.
    ///
    /// You may want to use this in queries to specify fetch conditions, for example:
    ///
    ///     box.query { .str59.startsWith("X") }

    internal static var str59: Property<UniqueEntity, String, Void> { return Property<UniqueEntity, String, Void>(propertyId: 63, isPrimaryKey: false) }

}


/// Generated service type to handle persisting and reading entity data. Exposed through `UniqueEntity.EntityBindingType`.
internal class UniqueEntityBinding: ObjectBox.EntityBinding {
    internal typealias EntityType = UniqueEntity
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
        let propertyOffset_content = propertyCollector.prepare(string: entity.content)
        let propertyOffset_content2 = propertyCollector.prepare(string: entity.content2)
        let propertyOffset_str1 = propertyCollector.prepare(string: entity.str1)
        let propertyOffset_str2 = propertyCollector.prepare(string: entity.str2)
        let propertyOffset_str3 = propertyCollector.prepare(string: entity.str3)
        let propertyOffset_str4 = propertyCollector.prepare(string: entity.str4)
        let propertyOffset_str5 = propertyCollector.prepare(string: entity.str5)
        let propertyOffset_str6 = propertyCollector.prepare(string: entity.str6)
        let propertyOffset_str7 = propertyCollector.prepare(string: entity.str7)
        let propertyOffset_str8 = propertyCollector.prepare(string: entity.str8)
        let propertyOffset_str9 = propertyCollector.prepare(string: entity.str9)
        let propertyOffset_str10 = propertyCollector.prepare(string: entity.str10)
        let propertyOffset_str11 = propertyCollector.prepare(string: entity.str11)
        let propertyOffset_str12 = propertyCollector.prepare(string: entity.str12)
        let propertyOffset_str13 = propertyCollector.prepare(string: entity.str13)
        let propertyOffset_str14 = propertyCollector.prepare(string: entity.str14)
        let propertyOffset_str15 = propertyCollector.prepare(string: entity.str15)
        let propertyOffset_str16 = propertyCollector.prepare(string: entity.str16)
        let propertyOffset_str17 = propertyCollector.prepare(string: entity.str17)
        let propertyOffset_str18 = propertyCollector.prepare(string: entity.str18)
        let propertyOffset_str19 = propertyCollector.prepare(string: entity.str19)
        let propertyOffset_str20 = propertyCollector.prepare(string: entity.str20)
        let propertyOffset_str21 = propertyCollector.prepare(string: entity.str21)
        let propertyOffset_str22 = propertyCollector.prepare(string: entity.str22)
        let propertyOffset_str23 = propertyCollector.prepare(string: entity.str23)
        let propertyOffset_str24 = propertyCollector.prepare(string: entity.str24)
        let propertyOffset_str25 = propertyCollector.prepare(string: entity.str25)
        let propertyOffset_str26 = propertyCollector.prepare(string: entity.str26)
        let propertyOffset_str27 = propertyCollector.prepare(string: entity.str27)
        let propertyOffset_str28 = propertyCollector.prepare(string: entity.str28)
        let propertyOffset_str29 = propertyCollector.prepare(string: entity.str29)
        let propertyOffset_str30 = propertyCollector.prepare(string: entity.str30)
        let propertyOffset_str31 = propertyCollector.prepare(string: entity.str31)
        let propertyOffset_str32 = propertyCollector.prepare(string: entity.str32)
        let propertyOffset_str33 = propertyCollector.prepare(string: entity.str33)
        let propertyOffset_str34 = propertyCollector.prepare(string: entity.str34)
        let propertyOffset_str35 = propertyCollector.prepare(string: entity.str35)
        let propertyOffset_str36 = propertyCollector.prepare(string: entity.str36)
        let propertyOffset_str37 = propertyCollector.prepare(string: entity.str37)
        let propertyOffset_str38 = propertyCollector.prepare(string: entity.str38)
        let propertyOffset_str39 = propertyCollector.prepare(string: entity.str39)
        let propertyOffset_str40 = propertyCollector.prepare(string: entity.str40)
        let propertyOffset_str41 = propertyCollector.prepare(string: entity.str41)
        let propertyOffset_str42 = propertyCollector.prepare(string: entity.str42)
        let propertyOffset_str43 = propertyCollector.prepare(string: entity.str43)
        let propertyOffset_str44 = propertyCollector.prepare(string: entity.str44)
        let propertyOffset_str45 = propertyCollector.prepare(string: entity.str45)
        let propertyOffset_str46 = propertyCollector.prepare(string: entity.str46)
        let propertyOffset_str47 = propertyCollector.prepare(string: entity.str47)
        let propertyOffset_str48 = propertyCollector.prepare(string: entity.str48)
        let propertyOffset_str49 = propertyCollector.prepare(string: entity.str49)
        let propertyOffset_str50 = propertyCollector.prepare(string: entity.str50)
        let propertyOffset_str51 = propertyCollector.prepare(string: entity.str51)
        let propertyOffset_str52 = propertyCollector.prepare(string: entity.str52)
        let propertyOffset_str53 = propertyCollector.prepare(string: entity.str53)
        let propertyOffset_str54 = propertyCollector.prepare(string: entity.str54)
        let propertyOffset_str55 = propertyCollector.prepare(string: entity.str55)
        let propertyOffset_str56 = propertyCollector.prepare(string: entity.str56)
        let propertyOffset_str57 = propertyCollector.prepare(string: entity.str57)
        let propertyOffset_str58 = propertyCollector.prepare(string: entity.str58)
        let propertyOffset_str59 = propertyCollector.prepare(string: entity.str59)

        propertyCollector.collect(id, at: 2 + 2 * 1)
        propertyCollector.collect(dataOffset: propertyOffset_name, at: 2 + 2 * 2)
        propertyCollector.collect(dataOffset: propertyOffset_content, at: 2 + 2 * 3)
        propertyCollector.collect(dataOffset: propertyOffset_content2, at: 2 + 2 * 4)
        propertyCollector.collect(dataOffset: propertyOffset_str1, at: 2 + 2 * 5)
        propertyCollector.collect(dataOffset: propertyOffset_str2, at: 2 + 2 * 6)
        propertyCollector.collect(dataOffset: propertyOffset_str3, at: 2 + 2 * 7)
        propertyCollector.collect(dataOffset: propertyOffset_str4, at: 2 + 2 * 8)
        propertyCollector.collect(dataOffset: propertyOffset_str5, at: 2 + 2 * 9)
        propertyCollector.collect(dataOffset: propertyOffset_str6, at: 2 + 2 * 10)
        propertyCollector.collect(dataOffset: propertyOffset_str7, at: 2 + 2 * 11)
        propertyCollector.collect(dataOffset: propertyOffset_str8, at: 2 + 2 * 12)
        propertyCollector.collect(dataOffset: propertyOffset_str9, at: 2 + 2 * 13)
        propertyCollector.collect(dataOffset: propertyOffset_str10, at: 2 + 2 * 14)
        propertyCollector.collect(dataOffset: propertyOffset_str11, at: 2 + 2 * 15)
        propertyCollector.collect(dataOffset: propertyOffset_str12, at: 2 + 2 * 16)
        propertyCollector.collect(dataOffset: propertyOffset_str13, at: 2 + 2 * 17)
        propertyCollector.collect(dataOffset: propertyOffset_str14, at: 2 + 2 * 18)
        propertyCollector.collect(dataOffset: propertyOffset_str15, at: 2 + 2 * 19)
        propertyCollector.collect(dataOffset: propertyOffset_str16, at: 2 + 2 * 20)
        propertyCollector.collect(dataOffset: propertyOffset_str17, at: 2 + 2 * 21)
        propertyCollector.collect(dataOffset: propertyOffset_str18, at: 2 + 2 * 22)
        propertyCollector.collect(dataOffset: propertyOffset_str19, at: 2 + 2 * 23)
        propertyCollector.collect(dataOffset: propertyOffset_str20, at: 2 + 2 * 24)
        propertyCollector.collect(dataOffset: propertyOffset_str21, at: 2 + 2 * 25)
        propertyCollector.collect(dataOffset: propertyOffset_str22, at: 2 + 2 * 26)
        propertyCollector.collect(dataOffset: propertyOffset_str23, at: 2 + 2 * 27)
        propertyCollector.collect(dataOffset: propertyOffset_str24, at: 2 + 2 * 28)
        propertyCollector.collect(dataOffset: propertyOffset_str25, at: 2 + 2 * 29)
        propertyCollector.collect(dataOffset: propertyOffset_str26, at: 2 + 2 * 30)
        propertyCollector.collect(dataOffset: propertyOffset_str27, at: 2 + 2 * 31)
        propertyCollector.collect(dataOffset: propertyOffset_str28, at: 2 + 2 * 32)
        propertyCollector.collect(dataOffset: propertyOffset_str29, at: 2 + 2 * 33)
        propertyCollector.collect(dataOffset: propertyOffset_str30, at: 2 + 2 * 34)
        propertyCollector.collect(dataOffset: propertyOffset_str31, at: 2 + 2 * 35)
        propertyCollector.collect(dataOffset: propertyOffset_str32, at: 2 + 2 * 36)
        propertyCollector.collect(dataOffset: propertyOffset_str33, at: 2 + 2 * 37)
        propertyCollector.collect(dataOffset: propertyOffset_str34, at: 2 + 2 * 38)
        propertyCollector.collect(dataOffset: propertyOffset_str35, at: 2 + 2 * 39)
        propertyCollector.collect(dataOffset: propertyOffset_str36, at: 2 + 2 * 40)
        propertyCollector.collect(dataOffset: propertyOffset_str37, at: 2 + 2 * 41)
        propertyCollector.collect(dataOffset: propertyOffset_str38, at: 2 + 2 * 42)
        propertyCollector.collect(dataOffset: propertyOffset_str39, at: 2 + 2 * 43)
        propertyCollector.collect(dataOffset: propertyOffset_str40, at: 2 + 2 * 44)
        propertyCollector.collect(dataOffset: propertyOffset_str41, at: 2 + 2 * 45)
        propertyCollector.collect(dataOffset: propertyOffset_str42, at: 2 + 2 * 46)
        propertyCollector.collect(dataOffset: propertyOffset_str43, at: 2 + 2 * 47)
        propertyCollector.collect(dataOffset: propertyOffset_str44, at: 2 + 2 * 48)
        propertyCollector.collect(dataOffset: propertyOffset_str45, at: 2 + 2 * 49)
        propertyCollector.collect(dataOffset: propertyOffset_str46, at: 2 + 2 * 50)
        propertyCollector.collect(dataOffset: propertyOffset_str47, at: 2 + 2 * 51)
        propertyCollector.collect(dataOffset: propertyOffset_str48, at: 2 + 2 * 52)
        propertyCollector.collect(dataOffset: propertyOffset_str49, at: 2 + 2 * 53)
        propertyCollector.collect(dataOffset: propertyOffset_str50, at: 2 + 2 * 54)
        propertyCollector.collect(dataOffset: propertyOffset_str51, at: 2 + 2 * 55)
        propertyCollector.collect(dataOffset: propertyOffset_str52, at: 2 + 2 * 56)
        propertyCollector.collect(dataOffset: propertyOffset_str53, at: 2 + 2 * 57)
        propertyCollector.collect(dataOffset: propertyOffset_str54, at: 2 + 2 * 58)
        propertyCollector.collect(dataOffset: propertyOffset_str55, at: 2 + 2 * 59)
        propertyCollector.collect(dataOffset: propertyOffset_str56, at: 2 + 2 * 60)
        propertyCollector.collect(dataOffset: propertyOffset_str57, at: 2 + 2 * 61)
        propertyCollector.collect(dataOffset: propertyOffset_str58, at: 2 + 2 * 62)
        propertyCollector.collect(dataOffset: propertyOffset_str59, at: 2 + 2 * 63)
    }

    internal func createEntity(entityReader: ObjectBox.FlatBufferReader, store: ObjectBox.Store) -> EntityType {
        let entity = UniqueEntity()

        entity.id = entityReader.read(at: 2 + 2 * 1)
        entity.name = entityReader.read(at: 2 + 2 * 2)
        entity.content = entityReader.read(at: 2 + 2 * 3)
        entity.content2 = entityReader.read(at: 2 + 2 * 4)
        entity.str1 = entityReader.read(at: 2 + 2 * 5)
        entity.str2 = entityReader.read(at: 2 + 2 * 6)
        entity.str3 = entityReader.read(at: 2 + 2 * 7)
        entity.str4 = entityReader.read(at: 2 + 2 * 8)
        entity.str5 = entityReader.read(at: 2 + 2 * 9)
        entity.str6 = entityReader.read(at: 2 + 2 * 10)
        entity.str7 = entityReader.read(at: 2 + 2 * 11)
        entity.str8 = entityReader.read(at: 2 + 2 * 12)
        entity.str9 = entityReader.read(at: 2 + 2 * 13)
        entity.str10 = entityReader.read(at: 2 + 2 * 14)
        entity.str11 = entityReader.read(at: 2 + 2 * 15)
        entity.str12 = entityReader.read(at: 2 + 2 * 16)
        entity.str13 = entityReader.read(at: 2 + 2 * 17)
        entity.str14 = entityReader.read(at: 2 + 2 * 18)
        entity.str15 = entityReader.read(at: 2 + 2 * 19)
        entity.str16 = entityReader.read(at: 2 + 2 * 20)
        entity.str17 = entityReader.read(at: 2 + 2 * 21)
        entity.str18 = entityReader.read(at: 2 + 2 * 22)
        entity.str19 = entityReader.read(at: 2 + 2 * 23)
        entity.str20 = entityReader.read(at: 2 + 2 * 24)
        entity.str21 = entityReader.read(at: 2 + 2 * 25)
        entity.str22 = entityReader.read(at: 2 + 2 * 26)
        entity.str23 = entityReader.read(at: 2 + 2 * 27)
        entity.str24 = entityReader.read(at: 2 + 2 * 28)
        entity.str25 = entityReader.read(at: 2 + 2 * 29)
        entity.str26 = entityReader.read(at: 2 + 2 * 30)
        entity.str27 = entityReader.read(at: 2 + 2 * 31)
        entity.str28 = entityReader.read(at: 2 + 2 * 32)
        entity.str29 = entityReader.read(at: 2 + 2 * 33)
        entity.str30 = entityReader.read(at: 2 + 2 * 34)
        entity.str31 = entityReader.read(at: 2 + 2 * 35)
        entity.str32 = entityReader.read(at: 2 + 2 * 36)
        entity.str33 = entityReader.read(at: 2 + 2 * 37)
        entity.str34 = entityReader.read(at: 2 + 2 * 38)
        entity.str35 = entityReader.read(at: 2 + 2 * 39)
        entity.str36 = entityReader.read(at: 2 + 2 * 40)
        entity.str37 = entityReader.read(at: 2 + 2 * 41)
        entity.str38 = entityReader.read(at: 2 + 2 * 42)
        entity.str39 = entityReader.read(at: 2 + 2 * 43)
        entity.str40 = entityReader.read(at: 2 + 2 * 44)
        entity.str41 = entityReader.read(at: 2 + 2 * 45)
        entity.str42 = entityReader.read(at: 2 + 2 * 46)
        entity.str43 = entityReader.read(at: 2 + 2 * 47)
        entity.str44 = entityReader.read(at: 2 + 2 * 48)
        entity.str45 = entityReader.read(at: 2 + 2 * 49)
        entity.str46 = entityReader.read(at: 2 + 2 * 50)
        entity.str47 = entityReader.read(at: 2 + 2 * 51)
        entity.str48 = entityReader.read(at: 2 + 2 * 52)
        entity.str49 = entityReader.read(at: 2 + 2 * 53)
        entity.str50 = entityReader.read(at: 2 + 2 * 54)
        entity.str51 = entityReader.read(at: 2 + 2 * 55)
        entity.str52 = entityReader.read(at: 2 + 2 * 56)
        entity.str53 = entityReader.read(at: 2 + 2 * 57)
        entity.str54 = entityReader.read(at: 2 + 2 * 58)
        entity.str55 = entityReader.read(at: 2 + 2 * 59)
        entity.str56 = entityReader.read(at: 2 + 2 * 60)
        entity.str57 = entityReader.read(at: 2 + 2 * 61)
        entity.str58 = entityReader.read(at: 2 + 2 * 62)
        entity.str59 = entityReader.read(at: 2 + 2 * 63)

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
    try AuthorStruct.buildEntity(modelBuilder: modelBuilder)
    try Note.buildEntity(modelBuilder: modelBuilder)
    try NoteStruct.buildEntity(modelBuilder: modelBuilder)
    try Student.buildEntity(modelBuilder: modelBuilder)
    try Teacher.buildEntity(modelBuilder: modelBuilder)
    try UniqueEntity.buildEntity(modelBuilder: modelBuilder)
    modelBuilder.lastEntity(id: 7, uid: 6258744021471265280)
    modelBuilder.lastIndex(id: 3, uid: 4943227758701996288)
    modelBuilder.lastRelation(id: 3, uid: 417604695477796352)
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

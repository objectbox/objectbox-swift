//
//  Copyright © 2019 objectbox. All rights reserved.
//

import Foundation
import ObjectBox

class Note: Entity {
    var id: Id = 0 
    var title: String = "" {
        didSet {
            modificationDate = Date()
        }
    }
    var text: String = "" {
        didSet {
            modificationDate = Date()
        }
    }
    var creationDate: Date? = Date()
    var modificationDate: Date?
    var author: ToOne<Author> = nil
    var done: Bool = false
    var upvotes: UInt32 = 0
    
    // An initializer with no parameters is required by ObjectBox
    required init() {
        // Nothing to do since we initialize the properties upon declaration here.
        // See `Author` for a different approach
    }
    
    convenience init(title: String, text: String) {
        self.init()
        self.title = title
        self.text = text
    }
}

// objectbox:Entity
struct NoteStruct {
    var id: Id = 0
    var title: String = "" {
        didSet {
            modificationDate = Date()
        }
    }
    var text: String = "" {
        didSet {
            modificationDate = Date()
        }
    }
    var creationDate: Date? = Date()
    var modificationDate: Date?
    var author: ToOne<Author> = nil
}

// objectbox:Entity
class Author {
    var id: EntityId<Author> = 0
    var name: String

    var notesStandalone: ToMany<Note>

    // objectbox: backlink = "author"
    var notes: ToMany<Note>
    var yearOfBirth: UInt16?


    // An initializer with no parameters is required by ObjectBox
    required init() {
        self.id = 0
        self.name = ""
        self.notes = nil
        self.notesStandalone = nil
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// objectbox:Entity
struct AuthorStruct {
    var id: EntityId<AuthorStruct> = 0
    var name: String
    var notes: ToMany<NoteStruct>
}

// objectbox:Entity
class Teacher {
    var id: Id = 0
    var name: String

    // objectbox:backlink = "teachers"
    var students: ToMany<Student> = nil

    required init() {
        self.id = 0
        self.name = ""
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// objectbox:Entity
class Student {
    var id: Id = 0
    var name: String

    var teachers: ToMany<Teacher> = nil

    required init() {
        self.id = 0
        self.name = ""
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

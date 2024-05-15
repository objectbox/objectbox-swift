//
//  Copyright © 2019-2023 ObjectBox. All rights reserved.
//

// Note: Use the script generate.rb to manually update EntityInfo.generated.swift
// TODO/Warning: This seems not to be used in our standard unit tests. Might make sense; check TestEntities too.

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
    var id: Id = 0
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
    var id: Id = 0
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

// objectbox:Entity
class UniqueEntity {
    var id: Id = 0
    // objectbox:unique
    var name: String = ""
    var content: String = ""
    var content2: String = ""
    var str1: String = ""
    var str2: String = ""
    var str3: String = ""
    var str4: String = ""
    var str5: String = ""
    var str6: String = ""
    var str7: String = ""
    var str8: String = ""
    var str9: String = ""
    var str10: String = ""
    var str11: String = ""
    var str12: String = ""
    var str13: String = ""
    var str14: String = ""
    var str15: String = ""
    var str16: String = ""
    var str17: String = ""
    var str18: String = ""
    var str19: String = ""
    var str20: String = ""
    var str21: String = ""
    var str22: String = ""
    var str23: String = ""
    var str24: String = ""
    var str25: String = ""
    var str26: String = ""
    var str27: String = ""
    var str28: String = ""
    var str29: String = ""
    var str30: String = ""
    var str31: String = ""
    var str32: String = ""
    var str33: String = ""
    var str34: String = ""
    var str35: String = ""
    var str36: String = ""
    var str37: String = ""
    var str38: String = ""
    var str39: String = ""
    var str40: String = ""
    var str41: String = ""
    var str42: String = ""
    var str43: String = ""
    var str44: String = ""
    var str45: String = ""
    var str46: String = ""
    var str47: String = ""
    var str48: String = ""
    var str49: String = ""
    var str50: String = ""
    var str51: String = ""
    var str52: String = ""
    var str53: String = ""
    var str54: String = ""
    var str55: String = ""
    var str56: String = ""
    var str57: String = ""
    var str58: String = ""
    var str59: String = ""

    required init() {
    }

    convenience init(name: String, content: String = "", content2: String = "") {
        self.init()
        self.name = name
        self.content = content
        self.content2 = content2
    }
}

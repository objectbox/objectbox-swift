//  Copyright © 2018 ObjectBox. All rights reserved.

import ObjectBox

class Author: Entity {
    var id: Id<Author>
    var name: String
    var notes: ToMany<Note, Author> // Backlinks

    required init() {
        self.id = 0
        self.name = ""
        self.notes = nil
    }
}

class Note: Entity {
    var id: Id<Note> = 0
    var title: String = ""
    var text: String = ""
    var author: ToOne<Author> = nil

    required init() {
        self.id = 0
        self.title = ""
        self.text = ""
        self.author = nil
    }
}

// The following explicit type and property declarations are used by ToOne/ToMany relations
// in this preliminary release. They will not be required in future releases.

extension Author {
    typealias EntityType = Author
    var _id: Id<Author> { return id }
}

extension Note {
    typealias EntityType = Note
    var _id: Id<Note> { return id }
}

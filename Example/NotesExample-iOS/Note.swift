//  Copyright © 2018 ObjectBox. All rights reserved.

import ObjectBox

class Author: ObjectBox.Entity {
    var id: Id<Author> = 0
    var name: String = ""
    var notes: ToMany<Note, Author> = nil // Backlinks
}

class Note: ObjectBox.Entity {
    var id: Id<Note> = 0
    var title: String = ""
    var text: String = ""
    var notes: ToOne<Author> = nil
}

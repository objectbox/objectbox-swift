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

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

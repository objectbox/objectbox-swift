//  Copyright © 2018 ObjectBox. All rights reserved.

import ObjectBox

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

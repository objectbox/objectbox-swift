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

    convenience init(title: String, text: String) {
        self.init()
        self.title = title
        self.text = text
    }
}

extension Note: CustomStringConvertible {
    var description: String {
        let authorDesc: String = {
            if let id = author.targetId {
                return "Id(\(id.value))"
            }
            return "(none)"
        }()
        return "Note(id: \(id.value), title: \"\(title)\", text: \"\(text)\", author: \(authorDesc))"
    }
}

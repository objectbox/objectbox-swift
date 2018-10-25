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
            if let author = author.target {
                return "\(author.name) (id: \(author.id.value))"
            }
            return "(none)"
        }()
        return "Note(id: \(id.value), title: \"\(title)\", text: \"\(text)\", author: \(authorDesc))"
    }
}

extension Array where Element: Note {
    var readableDescription: String {
        return "[\n"
            + self.map({"  \($0.description)"}).joined(separator: "\n")
            + "\n]"
    }
}

//  Copyright © 2018 ObjectBox. All rights reserved.

import ObjectBox

// objectbox:Entity
class Author {
    var id: Id // An ID is required by ObjectBox
    var name: String
    // objectbox: backlink = "author"
    var notes: ToMany<Note>

    // An initializer with no parameters is required by ObjectBox
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

extension Author: CustomStringConvertible {
    var description: String {
        let noteTitles = notes.map { $0.title }
        let address = withUnsafePointer(to: self, { "\($0)" })
        return "Author(id: \(id.value), name: \(name), notes: \(noteTitles)) @ \(address)"
    }
}

extension Author {
    func writeNote(title: String, text: String) -> Note {
        let note = Note(title: title, text: text)
        note.author.target = self
        return note
    }
}

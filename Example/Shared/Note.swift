//  Copyright © 2018 ObjectBox. All rights reserved.

import ObjectBox
import Foundation

class Note: Entity {
    var id: Id = 0 // An ID is required by ObjectBox
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

//  Copyright © 2018 ObjectBox. All rights reserved.

import ObjectBox

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

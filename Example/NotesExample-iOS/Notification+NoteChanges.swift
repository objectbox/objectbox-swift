//  Copyright © 2018 ObjectBox. All rights reserved.

import Foundation

extension Notification.Name {
    /// Its `userInfo` provides `oldValue` and `newValue` Strings.
    static var noteTitleDidChange: Notification.Name { return .init("OB_NoteTitleDidChange") }

    /// - If the note had an author before the change, `userInfo["oldValue"]` contains the old ID value.
    /// - If the note has an author after the change, `userInfo["newValue"]` contains the new ID value.
    static var noteAuthorDidChange: Notification.Name { return .init("OB_NoteAuthorDidChange") }
}

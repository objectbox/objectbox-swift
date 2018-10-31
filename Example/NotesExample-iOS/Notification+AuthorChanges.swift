//  Copyright © 2018 ObjectBox. All rights reserved.

import Foundation

extension Notification.Name {
    /// Its `userInfo` provides `oldValue` and `newValue` Strings.
    static var authorNameDidChange: Notification.Name { return .init("OB_AuthorNameDidChange") }

    static var authorAdded: Notification.Name { return .init("OB_AuthorAdded") }
}

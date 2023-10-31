//  Copyright © 2018 ObjectBox. All rights reserved.

import ObjectBox
import Foundation

extension Store {
    /// Creates a new ObjectBox.Store in a temporary directory.
    static func createStoreInTemporaryDirectory() throws -> Store {
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: FileManager.SearchPathDomainMask.userDomainMask,
            appropriateFor: nil,
            create: true).appendingPathComponent(Bundle.main.bundleIdentifier!)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false, attributes: nil)
        }
        return try Store(directoryPath: directory.path)
    }
}

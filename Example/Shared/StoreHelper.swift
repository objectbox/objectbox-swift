//  Copyright © 2018 ObjectBox. All rights reserved.

import ObjectBox

extension Store {
    /// Creates a new ObjectBox.Store in a temporary directory.
    static func createStoreInTemporaryDirectory() throws -> Store {
        let directory = try newTemporaryDirectory().path
        return try Store(
            directoryPath: directory,
            maxDbSizeInKByte: 500,
            fileMode: 0o755,
            maxReaders: 10)
    }
}

private func newTemporaryDirectory() throws -> URL {
    let path = topLevelTemporaryDirectory().appendingPathComponent(UUID().uuidString)
    try ensurePathExists(path: path)
    return path
}

private func topLevelTemporaryDirectory() -> URL {
    //    let tempURL = try FileManager.default.url(
    //        for: FileManager.SearchPathDirectory.itemReplacementDirectory,
    //        in: FileManager.SearchPathDomainMask.userDomainMask,
    //        appropriateFor: URL(fileURLWithPath: "objectbox"),
    //        create: true)
    return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("objectbox")
}

private func ensurePathExists(path: URL) throws {
    if !FileManager.default.fileExists(atPath: path.path) {
        try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
    }
}

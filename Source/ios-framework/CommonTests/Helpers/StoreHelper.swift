//
// Copyright © 2019 ObjectBox Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// :nodoc:
public class StoreHelper {
    /// :nodoc:
    public class func tempStore(model: OpaquePointer /*OBX_model*/, maxDbSizeInKByte: UInt64 = 500) -> Store {
        let inMemoryEnv = ProcessInfo.processInfo.environment["OBX_IN_MEMORY"]
        let inMemory = inMemoryEnv != nil && inMemoryEnv == "true"
        if (inMemory) {
            print("Using in-memory database for testing")
        }
        let directoryPath = inMemory ? "memory:testdata" : StoreHelper.newTemporaryDirectory().path
        var store: Store! = nil
        do {
            store = try Store(model: model, directory: directoryPath, maxDbSizeInKByte: maxDbSizeInKByte,
                    fileMode: 0o644, maxReaders: 10)
        } catch {
            NSException(name: NSExceptionName.genericException, reason: "tempStore failed with error: \(error)",
                    userInfo: [NSUnderlyingErrorKey: error]).raise()
        }
        return store
    }

    /// :nodoc:
    public class func newTemporaryDirectory() -> URL {
        let base = temporaryDirectoryBase()
        ensurePathExists(base)
        let directoryURL = base.appendingPathComponent(UUID().uuidString)
        let path = directoryURL.path
        if FileManager.default.fileExists(atPath: path) {
            fatalError("Random dir already exists: " + path)
        }
        print("Test store will be created at temp path " + path)
        return directoryURL
    }

    internal class func temporaryDirectoryBase() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("objectbox-test")
    }

    internal class func ensurePathExists(_ url: URL) {
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("Could not create dir: " + url.path)
            }
        }
    }
}

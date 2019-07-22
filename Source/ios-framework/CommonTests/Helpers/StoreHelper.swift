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
    public class func tempStore(model: OpaquePointer /*OBX_model*/) -> Store {
        let directoryPath = StoreHelper.newTemporaryDirectory().path
        var store: Store! = nil
        do {
            store = try Store(model: model, directory: directoryPath, maxDbSizeInKByte: 500, fileMode: 0o755,
                              maxReaders: 10)
        } catch {
            NSException(name: NSExceptionName.genericException, reason: "tempStore failed with error: \(error)",
                userInfo: [NSUnderlyingErrorKey: error]).raise()
        }
        return store
    }
    
    /// :nodoc:
    public class func newTemporaryDirectory() -> URL {
        let directoryURL = temporaryDirectoryBase().appendingPathComponent(UUID().uuidString)
        do {
            try ensurePathExists(directoryURL)
        } catch {
            NSException(name: NSExceptionName.genericException,
                        reason: "Cannot create temporary directory at \(directoryURL.path), "
                            + "error: \(error)", userInfo: ["URL": directoryURL]).raise()
        }
        return directoryURL
    }
    
    internal class func temporaryDirectoryBase() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("objectbox-test")
    }
    
    internal class func ensurePathExists(_ url: URL) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
    }
}

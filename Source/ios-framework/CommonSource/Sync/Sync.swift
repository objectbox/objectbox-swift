//
// Copyright (c) 2020 ObjectBox. All rights reserved.
//

import Foundation

/// "Point of entry" for sync, e.g. create a sync client using `Sync.makeClient(store, urlString)`.
/// For general information on ObjectBox Sync, please visit https://objectbox.io/sync.
/// General sync documentation - including Swift clients - is available at https://sync.objectbox.io/.
public class Sync {

    /// Checks if this library comes with a sync client.
    /// If you do not have a sync enabled version yet, please visit https://objectbox.io/sync for more details.
    /// - Returns: true if calling makeClient() is possible (without throwing)
    public static func isAvailable() -> Bool {
        return false // TODO obx_sync_available()
    }

    /// Creates a sync client associated with the given store and sync server with the given URL.
    /// This does not initiate any connection attempts yet: call start() to do so.
    /// Before start(), you can still configure some aspects of the sync client, e.g. its "request update" mode.
    ///
    /// Note: while you may not interact with SyncClient directly after start(), you need to hold on to the object:
    ///       by keeping a reference you ensure the SyncClient is not destroyed and thus synchronization can keep
    ///       running in the background. If you must, you can use Swift's withExtendedLifetime() for that.
    ///
    /// Pass either a `url` or a `urlString` (auto-converted to `URL`).
    ///
    /// - Throws: `ObjectBoxError.sync` if sync is unavailable in this version of the library
    ///           or no valid URL was provided.
    public static func makeClient(
            store: Store,
            url: URL? = nil,
            urlString: String? = nil,
            credentials: SyncCredentials? = nil
    ) throws -> SyncClient {
        guard isAvailable() else {
            throw ObjectBoxError.sync(
                    message: "Cannot create a new sync client: Sync is unavailable (correct library linked?)")
        }
        throw ObjectBoxError.sync(
                message:
                "Cannot create a new sync client: no Swift implementation available (but linked library supports it)")
    }
}

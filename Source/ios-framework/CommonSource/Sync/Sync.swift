//
// Copyright (c) 2020 ObjectBox. All rights reserved.
//

import Foundation

/// [ObjectBox Sync](https://objectbox.io/sync/) makes data available on other devices (check the link for details).
/// This class is the point of entry for Sync, e.g. create a sync client using `Sync.makeClient(store, urlString)`.
public class Sync {

    /// Checks if this library comes with a sync client.
    /// If you do not have a sync enabled version yet, please visit https://objectbox.io/sync for more details.
    /// - Returns: true if calling makeClient() is possible (without throwing)
    public static func isAvailable() -> Bool {
        return obx_has_feature(OBXFeature_Sync)
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
                    message: "This library does not include ObjectBox Sync. " +
                            "Please visit https://objectbox.io/sync/ for options.")
        }
        throw ObjectBoxError.sync(
                message:
                "Cannot create a new sync client: no Swift implementation available (but linked library supports it)")
    }
}

//
// Copyright (c) 2020-2025 ObjectBox. All rights reserved.
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
    /// To configure [Sync filter](https://sync.objectbox.io/sync-server/sync-filters) variables, pass
    /// variable names mapped to their value to `filterVariables` .
    ///
    /// Sync client filter variables can be used in server-side Sync filters to filter out objects that do not match
    /// the filter.
    ///
    /// To for example use self-signed certificates in a local development environment or custom CAs, pass certificate
    /// paths referring to the local file system to `certificatePaths`.
    ///
    /// - Throws: `ObjectBoxError.sync` if sync is unavailable in this version of the library
    ///           or no valid URL was provided.
    public static func makeClient(
        store: Store,
        url: URL? = nil,
        urlString: String? = nil,
        credentials: SyncCredentials? = nil,
        filterVariables: [String: String]? = nil,
        certificatePaths: [String] = []
    ) throws -> SyncClient {
        let client = try makeClient(store: store, url: url, urlString: urlString, filterVariables: filterVariables,
            certificatePaths: certificatePaths)

        if credentials != nil {
            try client.setCredentials(credentials!)
        }

        return client
    }

    /// Like ``makeClient(store:url:urlString:credentials:)-6rikk``, but accepts multiple credentials.
    public static func makeClient(
        store: Store,
        url: URL? = nil,
        urlString: String? = nil,
        credentials: [SyncCredentials],
        filterVariables: [String: String]? = nil,
        certificatePaths: [String] = []
    ) throws -> SyncClient {
        let client = try makeClient(store: store, url: url, urlString: urlString, filterVariables: filterVariables,
            certificatePaths: certificatePaths)

        try client.setCredentials(credentials)

        return client
    }

    private static func makeClient(
        store: Store,
        url: URL? = nil,
        urlString: String? = nil,
        filterVariables: [String: String]? = nil,
        certificatePaths: [String] = []
    ) throws -> SyncClientImpl {
        guard isAvailable() else {
            throw ObjectBoxError.sync(
                message: "This library does not include ObjectBox Sync. " +
                "Please visit https://objectbox.io/sync/ for options.")
        }
        guard store.syncClient == nil else {
            throw ObjectBoxError.sync(
                message: "Cannot create a new sync client: the store is already associated with a sync client")
        }
        var urlToConnect = url
        if urlToConnect == nil {
            if urlString == nil {
                throw ObjectBoxError.sync(message: "No URL provided")
            } else {
                urlToConnect = URL(string: urlString!)
                if urlToConnect == nil {
                    throw ObjectBoxError.sync(message: "Illegal URL given:" + urlString!)
                }
            }
        }

        let client = try SyncClientImpl(store: store, server: urlToConnect!, certificatePaths: certificatePaths)

        // Associate store with the new client: keep the client alive and provide convenient access to it
        store.syncClient = client  // This is not very atomic...

        if let filterVariables = filterVariables {
            for (name, value) in filterVariables {
                try client.putFilterVariable(name: name, value: value)
            }
        }

        return client
    }
}

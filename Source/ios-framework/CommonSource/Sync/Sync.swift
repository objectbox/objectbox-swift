//
// Copyright (c) 2020-2026 ObjectBox. https://objectbox.io
//

import Foundation

/// [ObjectBox Sync](https://objectbox.io/sync/) makes data available on other devices (check the link for details).
/// This class is the point of entry for Sync, e.g. create a sync client using `Sync.makeClient(store, configuration)`.
public class Sync {

    /// Configuration for creating a SyncClient.
    ///
    /// Use this class to configure the sync client before creation.
    ///
    /// Example:
    /// ```swift
    /// let configuration = Sync.Configuration(store: store, url: "wss://server.example.com")
    /// configuration.credentials = [.sharedSecret(mySecret)]
    /// let client = try Sync.makeClient(configuration: configuration)
    /// ```
    ///
    /// For Sync Server cluster setups, you can pass multiple URLs for high availability and load balancing.
    /// Like this, a random URL is selected for each connection attempt:
    /// ```swift
    /// let configuration = Sync.Configuration(
    ///     store: store,
    ///     urls: ["wss://server1.example.com", "wss://server2.example.com"])
    /// ```
    public class Configuration {
        /// The store to sync.
        public let store: Store

        /// Server URLs to connect to. Multiple URLs enable high availability and load balancing.
        public var urls: [String]

        /// Credentials to authenticate with the server.
        public var credentials: [SyncCredentials] = []

        /// SSL certificate paths for custom CAs or self-signed certificates.
        public var certificatePaths: [String] = []

        /// Flags to adjust sync behavior.
        public var flags: SyncFlags = []

        /// Filter variables for server-side sync filters.
        public var filterVariables: [String: String] = [:]

        /// Enable debug logging for sync client lifecycle and callbacks.
        public var debugLogging: Bool = false

        /// Creates a new configuration for the given store and server URL.
        /// - Parameters:
        ///   - store: The store to sync; a store can only have one sync client.
        ///   - url: The server URL (e.g., "wss://server.example.com")
        public init(store: Store, url: String) {
            self.store = store
            self.urls = [url]
        }

        /// Creates a new configuration for the given store and server URLs.
        /// Multiple URLs enable high availability and load balancing - a random one is selected for each connection.
        /// - Parameters:
        ///   - store: The store to sync; a store can only have one sync client.
        ///   - urls: The server URLs to connect to
        public init(store: Store, urls: [String]) {
            self.store = store
            self.urls = urls
        }
    }

    /// Checks if this library comes with a sync client.
    /// If you do not have a sync enabled version yet, please visit https://objectbox.io/sync for more details.
    /// - Returns: true if calling makeClient() is possible (without throwing)
    public static func isAvailable() -> Bool {
        return obx_has_feature(OBXFeature_Sync)
    }

    // MARK: - New Configuration-based API

    /// Creates a sync client with the given configuration.
    ///
    /// This does not initiate any connection attempts yet: call `start()` to do so.
    /// Before `start()`, you must set credentials on the configuration or call `setCredentials()` on the client.
    ///
    /// Note: while you may not interact with SyncClient directly after `start()`, you need to hold on to the object:
    /// by keeping a reference you ensure the SyncClient is not destroyed and thus synchronization can keep
    /// running in the background. If you must, you can use Swift's `withExtendedLifetime()` for that.
    ///
    /// - Parameter configuration: The configuration specifying URLs, credentials, and other options.
    /// - Throws: `ObjectBoxError.sync` if sync is unavailable or configuration is invalid.
    public static func makeClient(configuration: Configuration) throws -> SyncClient {
        guard isAvailable() else {
            throw ObjectBoxError.sync(
                message: "This library does not include ObjectBox Sync. " +
                "Please visit https://objectbox.io/sync/ for options.")
        }
        guard configuration.store.syncClient == nil else {
            throw ObjectBoxError.sync(
                message: "Cannot create a new sync client: the store is already associated with a sync client")
        }
        guard !configuration.urls.isEmpty else {
            throw ObjectBoxError.sync(message: "No URL provided. Call configuration.addURL() before creating client.")
        }

        let client = try SyncClientImpl(configuration: configuration)

        // Associate store with the new client
        configuration.store.syncClient = client

        return client
    }

    // MARK: - Deprecated API

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
    @available(*, deprecated, message: "Use makeClient(configuration:) instead")
    public static func makeClient(
        store: Store,
        url: URL? = nil,
        urlString: String? = nil,
        credentials: SyncCredentials? = nil,
        filterVariables: [String: String]? = nil,
        certificatePaths: [String] = [],
        debugLogging: Bool = false
    ) throws -> SyncClient {
        let configuration = configurationFromLegacyParams(
            store: store, url: url, urlString: urlString,
            filterVariables: filterVariables, certificatePaths: certificatePaths, debugLogging: debugLogging)
        if let creds = credentials {
            configuration.credentials = [creds]
        }
        return try makeClient(configuration: configuration)
    }

    /// Like ``makeClient(store:url:urlString:credentials:)-6rikk``, but accepts multiple credentials.
    @available(*, deprecated, message: "Use makeClient(configuration:) instead")
    public static func makeClient(
        store: Store,
        url: URL? = nil,
        urlString: String? = nil,
        credentials: [SyncCredentials],
        filterVariables: [String: String]? = nil,
        certificatePaths: [String] = [],
        debugLogging: Bool = false
    ) throws -> SyncClient {
        let configuration = configurationFromLegacyParams(
            store: store, url: url, urlString: urlString,
            filterVariables: filterVariables, certificatePaths: certificatePaths, debugLogging: debugLogging)
        configuration.credentials = credentials
        return try makeClient(configuration: configuration)
    }

    // swiftlint:disable:next function_parameter_count
    private static func configurationFromLegacyParams(
        store: Store,
        url: URL?,
        urlString: String?,
        filterVariables: [String: String]?,
        certificatePaths: [String],
        debugLogging: Bool
    ) -> Configuration {
        let urlToUse: String
        if let url = url {
            urlToUse = url.absoluteString
        } else {
            urlToUse = urlString ?? ""
        }
        let configuration = Configuration(store: store, url: urlToUse)
        configuration.certificatePaths = certificatePaths
        configuration.debugLogging = debugLogging
        if let filterVariables = filterVariables {
            configuration.filterVariables = filterVariables
        }
        return configuration
    }
}

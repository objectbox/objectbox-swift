//
// Copyright (c) 2020-2025 ObjectBox. All rights reserved.
//

import Foundation

// Internal note: sync implementation uses augmented C enums; maybe switch that to Swift enums too?

/// A SyncClient can use these types to login at the Sync Server.
public enum SyncCredentialsType: UInt32 {
    case none = 1,

        /// Deprecated, replaced by sharedSecret
         sharedSecretDeprecated = 2,

         googleAuth = 3,

        /// Uses shared secret to create a hashed credential.
         sharedSecret = 4,

        /// ObjectBox admin users (username/password)
         obxAdminUser = 5,

        /// Generic credential type suitable for ObjectBox admin
         userPassword = 6,

        /// JSON Web Token (JWT): an ID token that typically provides identity information about the authenticated user.
         jwtIdToken = 7,

        /// JSON Web Token (JWT): an access token that is used to access resources.
         jwtAccessToken = 8,

        /// JSON Web Token (JWT): a refresh token that is used to obtain a new access token.
         jwtRefreshToken = 9,

        /// JSON Web Token (JWT): a token that is neither an ID, access, nor refresh token.
         jwtCustomToken = 10
}

/// Configures how the sync client receives updates from the server after login.
public enum RequestUpdatesMode: UInt32 {
    /// No updates by default; `requestUpdates()` must be called manually.
    case manual = 0
    /// Automatically request updates on login and subscribe for future pushes (default).
    case auto = 1
    /// Automatically request updates on login, but do not subscribe for future pushes.
    case autoNoPushes = 2
}

/// The current state of a sync client.
public enum SyncState: UInt32 {
    /// Initial state after creation, before `start()` is called.
    case created = 1
    /// The client is trying to connect to the server.
    case started = 2
    /// Connection established; authentication (login) is pending.
    case connected = 3
    /// Logged in and operational; data can be sent and received.
    case loggedIn = 4
    /// Disconnected from the server; will typically reconnect automatically.
    case disconnected = 5
    /// Stopped by explicit `stop()` call; can be restarted.
    case stopped = 6
    /// The client is closed or in an unrecoverable error state.
    case dead = 7
}

/// Result codes returned by the sync server, e.g. on login failure.
public enum SyncCode: UInt32 {
    /// Success.
    case ok = 20
    /// The request was rejected by the server.
    case reqRejected = 40
    /// Authentication failed; credentials were rejected.
    case credentialsRejected = 43
    /// An unknown error occurred.
    case unknown = 50
    /// The authentication provider is unreachable.
    case authUnreachable = 53
    /// Protocol version mismatch; client or server needs to be updated.
    case badVersion = 55
    /// The client ID is already in use by another client.
    case clientIdTaken = 61
    /// A transaction violated a unique constraint.
    case txViolatedUnique = 71
}

/// Result of a timed wait operation, e.g. `waitForLoggedInState()`.
public enum SuccessTimeOut {
    /// The expected state was reached.
    case success
    /// A state was reached that indicates the operation will not succeed.
    case failure
    /// The timeout was reached before a conclusive state change.
    case timeout
}

/// Flags to adjust sync client behavior.
/// Combine multiple flags using array literal syntax, e.g. `[.debugLogIdMapping, .keepDataOnSyncError]`.
public struct SyncFlags: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// Enable (rather extensive) logging on how IDs are mapped (local <-> global)
    public static let debugLogIdMapping = SyncFlags(rawValue: 1)

    /// If the client gets in a state that does not allow any further synchronization, this flag instructs Sync to
    /// keep local data nevertheless. While this preserves data, you need to resolve the situation manually
    /// (e.g. backup the data and start with a fresh database).
    /// The default behavior (flag not set) is to wipe existing data from all sync-enabled types and sync from scratch.
    public static let keepDataOnSyncError = SyncFlags(rawValue: 2)

    /// Logs sync filter variables used for each client, e.g. values provided by JWT or the client's login message.
    public static let debugLogFilterVariables = SyncFlags(rawValue: 4)

    /// When set, remove operations will include the full object data in the TX log (REMOVE_OBJECT command).
    /// This allows sync filters to filter out remove operations based on the object content.
    /// Without this flag, remove operations only contain the object ID and cannot be filtered.
    /// Note: this increases the size of TX logs for remove operations.
    public static let removeWithObjectData = SyncFlags(rawValue: 8)

    /// Enables debug logging of TX log processing.
    public static let debugLogTxLogs = SyncFlags(rawValue: 16)

    /// Skips invalid (put object) operations in the TX log instead of failing.
    public static let skipInvalidTxOps = SyncFlags(rawValue: 32)
}

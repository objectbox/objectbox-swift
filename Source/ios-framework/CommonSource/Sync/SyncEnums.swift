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

/// Once logged in, do we request updates?
public enum RequestUpdatesMode: UInt32 {
    /// Do not request any updates automatically
    case manual = 0,
        /// Request updates automatically including subsequent pushes for data changes
         auto = 1,
        /// Request updates automatically once without subsequent pushes for data changes
         autoNoPushes = 2
}

public enum SyncState: UInt32 {
    case
            created = 1,
            started = 2,
            connected = 3,
            loggedIn = 4,
            disconnected = 5,
            stopped = 6,
            dead = 7
}

public enum SyncCode: UInt32 {
    case
            ok = 20,
            reqRejected = 40,
            credentialsRejected = 43,
            unknown = 50,
            authUnreachable = 53,
            badVersion = 55,
            clientIdTaken = 61,
            txViolatedUnique = 71
}

public enum SuccessTimeOut {
    case
            success,
            failure,
            timeout
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
    /// keep local data nevertheless. While this preserves data, you need to resolve the situation manually.
    /// Note that the default behavior (this flag is not set) is to wipe existing data from all sync-enabled types and
    /// sync from scratch from the server.
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

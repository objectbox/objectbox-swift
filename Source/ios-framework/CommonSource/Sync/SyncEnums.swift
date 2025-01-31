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

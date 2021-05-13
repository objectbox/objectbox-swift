//
// Copyright (c) 2020-2021 ObjectBox. All rights reserved.
//

import Foundation

// Internal note: sync implementation uses augmented C enums; maybe switch that to Swift enums too?

public enum SyncCredentialsType: UInt32 {
    case
            none = 1,
            sharedSecret = 2,
            googleAuth = 3
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

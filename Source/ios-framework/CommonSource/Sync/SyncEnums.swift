//
// Copyright (c) 2020 ObjectBox. All rights reserved.
//

import Foundation

// Internal note: sync implementation uses augmented C enums; maybe switch that to Swift enums too?

public enum SyncCredentialsType: UInt {
    case
            unchecked = 0,
            sharedSecret = 1,
            googleAuth = 2
}

public enum RequestUpdatesMode: UInt {
    case manual = 0,
         auto = 1,
         autoNoPushes = 2
}

public enum SyncState: UInt {
    case
            created = 1,
            started = 2,
            connected = 3,
            loggedIn = 4,
            disconnected = 5,
            stopped = 6,
            dead = 7
}

public enum SyncCode: UInt {
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

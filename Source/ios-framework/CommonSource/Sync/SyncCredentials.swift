//
// Copyright (c) 2020 ObjectBox. All rights reserved.
//

import Foundation

/// Credentials for authenticating the client when connecting to a sync server/peer.
/// E.g. use `SyncCredentials.makeSharedSecret(secret)`.
public class SyncCredentials {
    var type: SyncCredentialsType
    var data: Data

    init(type: SyncCredentialsType, data: Data) {
        self.type = type
        self.data = data
    }

    /// No authentication, insecure. Use only for development and testing purposes.
    public static func makeNone() -> SyncCredentials {
        return SyncCredentials(type: SyncCredentialsType.none, data: Data())
    }

    /// Authenticate with a pre-shared secret.
    public static func makeSharedSecret(_ data: Data) -> SyncCredentials {
        return SyncCredentials(type: SyncCredentialsType.sharedSecret, data: data)
    }

    /// Authenticate with a pre-shared key. The given string will be UTF-8 encoded.
    public static func makeSharedSecret(_ string: String) -> SyncCredentials {
        return makeSharedSecret(string.data(using: .utf8)!)
    }

}

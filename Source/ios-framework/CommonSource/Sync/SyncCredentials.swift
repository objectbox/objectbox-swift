//
// Copyright (c) 2020-2025 ObjectBox. All rights reserved.
//

import Foundation

/// Credentials for authenticating the client when connecting to a sync server/peer.
/// E.g. use `SyncCredentials.makeSharedSecret(secret)`.
public class SyncCredentials {
    var type: SyncCredentialsType
    var data: Data?
    var username: String?
    var password: String?

    init(type: SyncCredentialsType, data: Data) {
        self.type = type
        self.data = data
    }

    init(type: SyncCredentialsType, username: String, password: String) {
        self.type = type
        self.username = username
        self.password = password
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

    /// Authenticate with an ObjectBox Admin user(name) and a password.
    public static func makeObxAdminUser(_ username: String, _ password: String) -> SyncCredentials {
        return SyncCredentials(type: SyncCredentialsType.obxAdminUser, username: username, password: password)
    }

    /// Authenticate with a generic username and a password.
    /// The server configuration determines to which auth providers this goes to.
    public static func makeUsernamePassword(_ username: String, _ password: String) -> SyncCredentials {
        return SyncCredentials(type: SyncCredentialsType.userPassword, username: username, password: password)
    }

    /// Authenticate with a JWT ID token. The given string will be UTF-8 encoded.
    public static func makeJwtIdToken(_ jwtIdToken: String) -> SyncCredentials {
        return SyncCredentials(type: SyncCredentialsType.jwtIdToken, data: jwtIdToken.data(using: .utf8)!)
    }

    /// Authenticate with a JWT access token. The given string will be UTF-8 encoded.
    public static func makeJwtAccessToken(_ jwtAccessToken: String) -> SyncCredentials {
        return SyncCredentials(type: SyncCredentialsType.jwtAccessToken, data: jwtAccessToken.data(using: .utf8)!)
    }

    /// Authenticate with a JWT refresh token. The given string will be UTF-8 encoded.
    public static func makeJwtRefreshToken(_ jwtRefreshToken: String) -> SyncCredentials {
        return SyncCredentials(type: SyncCredentialsType.jwtRefreshToken, data: jwtRefreshToken.data(using: .utf8)!)
    }

    /// Authenticate with a JWT custom token. The given string will be UTF-8 encoded.
    public static func makeJwtCustomToken(_ jwtCustomToken: String) -> SyncCredentials {
        return SyncCredentials(type: SyncCredentialsType.jwtCustomToken, data: jwtCustomToken.data(using: .utf8)!)
    }

}

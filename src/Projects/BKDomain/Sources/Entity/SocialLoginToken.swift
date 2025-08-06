// Copyright © 2025 Booket. All rights reserved

public struct SocialLoginToken {
    public let identityToken: String
    public let authorizationCode: String?
    
    public init(
        identityToken: String,
        authorizationCode: String? = nil
    ) {
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
    }
}

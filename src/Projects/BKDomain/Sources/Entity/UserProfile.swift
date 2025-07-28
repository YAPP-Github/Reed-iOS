// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct UserProfile {
    public let id: String
    public let email: String
    public let nickname: String
    public let provider: String
    public let termsAgreed: Bool
    
    public init(id: String, email: String, nickname: String, provider: String, termsAgreed: Bool) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.provider = provider
        self.termsAgreed = termsAgreed
    }
}

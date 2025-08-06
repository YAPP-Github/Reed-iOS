// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

struct AuthLoginRequestDTO: Encodable {
    let providerType: AuthProvider
    let oauthToken: String
    let authorizationCode: String?
}

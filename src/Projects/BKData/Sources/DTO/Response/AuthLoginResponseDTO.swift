// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct AuthLoginResponseDTO: Decodable {
    public let accessToken: String
    public let refreshToken: String
}

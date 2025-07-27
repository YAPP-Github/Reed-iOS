// Copyright © 2025 Booket. All rights reserved

import BKDomain
import UIKit

public struct UserProfileResponseDTO: Decodable {
    public let id: String
    public let email: String
    public let nickname: String
    public let provider: String
    public let termsAgreed: Bool
}

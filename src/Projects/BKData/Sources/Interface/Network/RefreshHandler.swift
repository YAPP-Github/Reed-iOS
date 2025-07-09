// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine
import Foundation

public protocol RefreshHandler {
    func refresh(token refreshToken: String) -> AnyPublisher<Void, AuthError>
}

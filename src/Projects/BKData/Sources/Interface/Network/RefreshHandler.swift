// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine
import Foundation

public protocol RefreshHandler {
    func refresh(token accessToken: String) -> AnyPublisher<Void, AuthError>
}

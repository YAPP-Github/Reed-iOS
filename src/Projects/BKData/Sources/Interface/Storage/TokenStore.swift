// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine

public protocol TokenStore {
    func save(
        accessToken: String,
        refreshToken: String
    ) -> AnyPublisher<Void, TokenError>
    
    func clear() -> AnyPublisher<Void, TokenError>
}

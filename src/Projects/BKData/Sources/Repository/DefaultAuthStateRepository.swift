// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine
import Foundation

public struct DefaultAuthStateRepository: AuthStateRepository {
    private let tokenProvider: TokenProvider
    
    public init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    public func isLoggedIn() -> AnyPublisher<Bool, Never> {
        return Just(tokenProvider.accessToken != nil)
            .eraseToAnyPublisher()
    }
    
    public func accessToken() -> AnyPublisher<String?, Never> {
        return Just(tokenProvider.accessToken)
            .eraseToAnyPublisher()
    }
}

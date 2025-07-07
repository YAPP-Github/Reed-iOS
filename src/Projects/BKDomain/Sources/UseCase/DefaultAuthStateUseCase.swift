// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

public struct DefaultAuthStateUseCase: AuthStateUseCase {
    private let authStateRepository: AuthStateRepository
    
    public init(authStateRepository: AuthStateRepository) {
        self.authStateRepository = authStateRepository
    }
    
    public func execute() -> AnyPublisher<Bool, Never> {
        authStateRepository
            .isLoggedIn()
            .eraseToAnyPublisher()
    }
}

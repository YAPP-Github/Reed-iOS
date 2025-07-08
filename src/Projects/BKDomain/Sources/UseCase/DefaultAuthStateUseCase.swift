// Copyright © 2025 Booket. All rights reserved

import BKCore
import Combine
import Foundation

public struct DefaultAuthStateUseCase: AuthStateUseCase {
    private let authStateRepository: AuthStateRepository
    
    public init(authStateRepository: AuthStateRepository) {
        self.authStateRepository = authStateRepository
    }
    
    public func execute() -> AnyPublisher<Void, AuthError> {
        authStateRepository
            .isLoggedIn()
            .flatMap { _ in
                authStateRepository.validate()
            }
            .debugError(logger: AppLogger.auth)
            .eraseToAnyPublisher()
    }
}

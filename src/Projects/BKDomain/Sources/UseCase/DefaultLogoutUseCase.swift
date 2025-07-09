// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

public struct DefaultLogoutUseCase: LogoutUseCase {
    private let authRepository: AuthRepository
    
    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    public func execute() -> AnyPublisher<Void, AuthError> {
        return authRepository
            .logout()
            .eraseToAnyPublisher()
    }
}

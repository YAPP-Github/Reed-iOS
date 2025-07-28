// Copyright © 2025 Booket. All rights reserved

import Combine
import UIKit

public struct DefaultCheckTermsStateUseCase: CheckTermsStateUseCase {
    private let authStateRepository: AuthStateRepository
    
    public init(authStateRepository: AuthStateRepository) {
        self.authStateRepository = authStateRepository
    }
    
    public func execute() -> AnyPublisher<Bool, AuthError> {
        return authStateRepository.validate()
            .map { userProfile -> Bool in
                return userProfile.termsAgreed
            }
            .eraseToAnyPublisher()
    }
}

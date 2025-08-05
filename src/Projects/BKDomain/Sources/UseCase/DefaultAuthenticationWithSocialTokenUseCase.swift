// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

/// OAuth Provider를 통해 얻은 토큰을 백엔드에게 전송
public struct DefaultSocialTokenAuthUseCase: SocialTokenAuthUseCase {
    private let repository: AuthRepository
    
    public init(repository: AuthRepository) {
        self.repository = repository
    }
    
    public func execute(
        provider: AuthProvider,
        token: String,
        authorizationCode: String?
    ) -> AnyPublisher<Void, AuthError> {
        return repository.login(
            provider: provider,
            token: token,
            authorizationCode: authorizationCode
        )
    }
}

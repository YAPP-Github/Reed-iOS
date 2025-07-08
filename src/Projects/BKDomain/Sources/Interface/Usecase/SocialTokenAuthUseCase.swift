// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

/// OAuth Provider에게 식별 Token을 제공받는 UseCase
public protocol SocialTokenAuthUseCase {
    func execute(
        provider: AuthProvider,
        token: String
    ) -> AnyPublisher<Void, AuthError>
}

// Copyright © 2025 Booket. All rights reserved

import BKCore
import Combine
import Foundation

public struct DefaultSocialLoginUseCase: SocialLoginUseCase {
    private let loginService: SocialLoginService
    
    public init(loginService: SocialLoginService) {
        self.loginService = loginService
    }
    
    public func execute() -> AnyPublisher<String, AuthError> {
        return loginService
            .login()
            .eraseToAnyPublisher()
    }
}

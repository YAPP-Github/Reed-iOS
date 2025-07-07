// Copyright © 2025 Booket. All rights reserved

import BKCore
import Foundation

public struct DomainAssembly: Assembly {
    public init() {}
    
    public func assemble(container: DIContainer) {
        container.register(
            type: SocialTokenAuthUseCase.self
        ) { _ in
            @Autowired var repository: AuthRepository
            return DefaultSocialTokenAuthUseCase(
                repository: repository
            )
        }
        
        container.register(
            type: AuthStateUseCase.self
        ) { _ in
            @Autowired var repository: AuthStateRepository
            return DefaultAuthStateUseCase(
                authStateRepository: repository
            )
        }
        
        container.register(
            type: SocialLoginUseCase.self,
            name: "apple"
        ) { _ in
            @Autowired(name: "apple") var appleLoginService: SocialLoginService
            return DefaultSocialLoginUseCase(
                loginService: appleLoginService
            )
        }
        
        container.register(
            type: SocialLoginUseCase.self,
            name: "kakao"
        ) { _ in
            @Autowired(name: "kakao") var kakaoLoginService: SocialLoginService
            return DefaultSocialLoginUseCase(
                loginService: kakaoLoginService
            )
        }
    }
}

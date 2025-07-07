// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Foundation

public struct DataAssembly: Assembly {
    public init() {}
    
    public func assemble(container: DIContainer) {
        container.register(
            type: AuthRepository.self
        ) { _ in
            @Autowired(name: "oauth") var networkProvider: NetworkProvider
            @Autowired var tokenStore: TokenStore
            return DefaultAuthRepository(
                networkProvider: networkProvider,
                tokenStore: tokenStore
            )
        }
        
        container.register(
            type: AuthStateRepository.self
        ) { _ in
            @Autowired var tokenProvider: TokenProvider
            return DefaultAuthStateRepository(
                tokenProvider: tokenProvider
            )
        }
        
        container.register(
            type: SocialLoginService.self,
            name: "apple"
        ) { _ in
            return AppleLoginService()
        }
        
        container.register(
            type: SocialLoginService.self,
            name: "kakao"
        ) { _ in
            return KakaoLoginService()
        }
    }
}

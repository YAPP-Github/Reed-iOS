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
        
        container.register(
            type: LogoutUseCase.self
        ) { _ in
            @Autowired var repository: AuthRepository
            return DefaultLogoutUseCase(
                authRepository: repository
            )
        }
        
        container.register(
            type: AppVersionUseCase.self
        ) { _ in
            return DefaultAppVersionUseCase()
        }
        
        container.register(
            type: FetchRecentSearchUseCase.self
        ) { _ in
            @Autowired var repository: RecentSearchRepository
            return DefaultFetchRecentSearchUseCase(repository: repository)
        }
        
        container.register(
            type: StoreRecentSearchUseCase.self
        ) { _ in
            @Autowired var repository: RecentSearchRepository
            return DefaultStoreRecentSearchUseCase(repository: repository)
        }
        
        container.register(
            type: DeleteRecentSearchUseCase.self
        ) { _ in
            @Autowired var repository: RecentSearchRepository
            return DefaultDeleteRecentSearchUseCase(repository: repository)
        }
    }
}

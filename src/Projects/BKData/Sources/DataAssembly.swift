// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Foundation

public struct DataAssembly: Assembly {
    public init() {}
    
    public func assemble(container: DIContainer) {
        container.register(
            type: DefaultAuthRepository.self,
            scope: .singleton
        ) { _ in
            @Autowired var defaultProvider: NetworkProvider
            @Autowired(name: "OAuth") var oauthProvider: NetworkProvider
            @Autowired var tokenStore: TokenStore
            @Autowired var tokenProvider: TokenProvider
            return DefaultAuthRepository(
                defaultProvider: defaultProvider,
                oauthProvider: oauthProvider,
                tokenStore: tokenStore,
                tokenProvider: tokenProvider
            )
        }
        
        container.register(
            type: AuthStateRepository.self
        ) { _ in
            @Autowired(name: "OAuth") var networkProvider: NetworkProvider
            @Autowired var tokenProvider: TokenProvider
            return DefaultAuthStateRepository(
                networkProvider: networkProvider,
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
        
        container.register(
            type: AuthRepository.self
        ) { _ in
            @Autowired var repository: DefaultAuthRepository
            return repository
        }
        
        container.register(
            type: RecentSearchRepository.self
        ) { _ in
            @Autowired(name: "UserDefaults") var storage: KeyValueStorage
            return DefaultRecentSearchRepository(
                storage: storage,
                key: "recent_searches_default"
            )
        }
        
        container.register(
            type: RecentSearchRepository.self,
            name: "MyLibrary"
        ) { _ in
            @Autowired(name: "UserDefaults") var storage: KeyValueStorage
            return DefaultRecentSearchRepository(
                storage: storage,
                key: "recent_searches_my_library"
            )
        }
        
        container.register(
            type: BookRepository.self
        ) { _ in
            @Autowired(name: "OAuth") var networkProvider: NetworkProvider
            return DefaultBookRepository(networkProvider: networkProvider)
        }
        
        container.register(
            type: OnboardingRepository.self
        ) { _ in
            @Autowired(name: "UserDefaults") var storage: KeyValueStorage
            return DefaultOnboardingRepository(storage: storage)
        }
        
        container.register(
            type: RecordRepository.self
        ) { _ in
            @Autowired(name: "OAuth") var networkProvider: NetworkProvider
            return DefaultRecordRepository(networkProvider: networkProvider)
        }
        
        container.register(
            type: HomeRepository.self
        ) { _ in
            @Autowired(name: "OAuth") var networkProvider: NetworkProvider
            return DefaultHomeRepository(networkProvider: networkProvider)
        }
        
        container.register(
            type: RefreshHandler.self
        ) { _ in
            @Autowired var repository: DefaultAuthRepository
            return repository
        }
    }
}

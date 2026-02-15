// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Foundation
import FirebaseRemoteConfig

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
            @Autowired(name: "Default") var defaultNetworkProvider: NetworkProvider
            return DefaultBookRepository(
                networkProvider: networkProvider,
                defaultNetworkProvider: defaultNetworkProvider
            )
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
            type: SeedRepository.self
        ) { _ in
            @Autowired(name: "OAuth") var networkProvider: NetworkProvider
            return DefaultSeedRepository(networkProvider: networkProvider)
        }
        
        container.register(
            type: RefreshHandler.self
        ) { _ in
            @Autowired var repository: DefaultAuthRepository
            return repository
        }
        
        container.register(
            type: AppStoreRepository.self
        ) { _ in
            @Autowired var networkProvider: NetworkProvider
            return DefaultAppStoreRepository(networkProvider: networkProvider)
        }
        
        container.register(
            type: RemoteConfigRepository.self,
            scope: .singleton) { _ in
                let remoteConfig = RemoteConfig.remoteConfig()
                let settings = RemoteConfigSettings()
#if DEBUG
    settings.minimumFetchInterval = 0
#endif
                remoteConfig.configSettings = settings
                return DefaultRemoteConfigRepository(remoteConfig: remoteConfig)
            }


        container.register(
            type: NotificationRepository.self
        ) { _ in
            @Autowired(name: "OAuth") var networkProvider: NetworkProvider
            @Autowired var deviceIDProvider: DeviceIDProvider
            return DefaultNotificationRepository(
                networkProvider: networkProvider,
                deviceIDProvider: deviceIDProvider
            )
        }

        container.register(
            type: PushTokenRepository.self
        ) { _ in
            @Autowired var pushTokenProvider: PushTokenProvider
            @Autowired var pushTokenStore: PushTokenStore
            return DefaultPushTokenRepository(
                pushTokenProvider: pushTokenProvider,
                pushTokenStore: pushTokenStore
            )
        }

        container.register(type: ExternalLinkRepository.self) { _ in
            return DefaultExternalLinkRepository()
        }

        container.register(
            type: EmotionRepository.self,
            scope: .singleton
        ) { _ in
            @Autowired(name: "OAuth") var networkProvider: NetworkProvider
            return DefaultEmotionRepository(networkProvider: networkProvider)
        }
    }
}

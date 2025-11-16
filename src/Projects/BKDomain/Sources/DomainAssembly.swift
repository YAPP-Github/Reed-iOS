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
            type: TermsAgreeUseCase.self
        ) { _ in
            @Autowired var repository: AuthStateRepository
            return DefaultTermsAgreeUseCase(
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
            @Autowired var repository: AppStoreRepository
            return DefaultAppVersionUseCase(repository: repository)
        }
        
        container.register(
            type: FetchRemoteAppVersionUseCase.self
        ) { _ in
            @Autowired var repository: RemoteConfigRepository
            return DefaultFetchRemoteAppVersionUseCase(repository: repository)
        }
        
        container.register(
            type: SearchBookUseCase.self
        ) { _ in
            @Autowired var repository: BookRepository
            return DefaultSearchBookUseCase(repository: repository)
        }
        
        container.register(
            type: MyLibrarySearchBookUseCase.self
        ) { _ in
            @Autowired var repository: BookRepository
            return DefaultMyLibrarySearchBookUseCase(repository: repository)
        }
        
        // Default RecentSearch UseCases
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

        // MyLibrary RecentSearch UseCases
        container.register(
            type: FetchRecentSearchUseCase.self,
            name: "MyLibrary"
        ) { _ in
            @Autowired(name: "MyLibrary") var repository: RecentSearchRepository
            return DefaultFetchRecentSearchUseCase(repository: repository)
        }

        container.register(
            type: StoreRecentSearchUseCase.self,
            name: "MyLibrary"
        ) { _ in
            @Autowired(name: "MyLibrary") var repository: RecentSearchRepository
            return DefaultStoreRecentSearchUseCase(repository: repository)
        }

        container.register(
            type: DeleteRecentSearchUseCase.self,
            name: "MyLibrary"
        ) { _ in
            @Autowired(name: "MyLibrary") var repository: RecentSearchRepository
            return DefaultDeleteRecentSearchUseCase(repository: repository)
        }
        
        container.register(
            type: OnboardingCheckUseCase.self
        ) { _ in
            @Autowired var repository: OnboardingRepository
            return DefaultOnboardingCheckUseCase(repository: repository)
        }
        
        container.register(
            type: BookUpsertUseCase.self
        ) { _ in
            @Autowired var repository: BookRepository
            return DefaultBookUpsertUseCase(repository: repository)
        }
        
        container.register(
            type: CreateRecordUseCase.self
        ) { _ in
            @Autowired var repository: RecordRepository
            return DefaultCreateRecordUseCase(repository: repository)
        }
        
        container.register(
            type: MarkOnboardingSeenUseCase.self
        ) { _ in
            @Autowired var repository: OnboardingRepository
            return DefaultMarkOnboardingSeenUseCase(repository: repository)
        }
        
        container.register(
            type: FetchHomeUseCase.self
        ) { _ in
            @Autowired var repository: HomeRepository
            return DefaultFetchHomeUseCase(repository: repository)
        }
        
        container.register(
            type: FetchRecordDetailUseCase.self
        ) { _ in
            @Autowired var repository: RecordRepository
            return DefaultFetchRecordDetailUseCase(repository: repository)
        }
        
        container.register(
            type: FetchRecordsUseCase.self
        ) { _ in
            @Autowired var repository: RecordRepository
            return DefaultFetchRecordsUseCase(repository: repository)
        }
        
        container.register(
            type: FetchSeedStatsUseCase.self
        ) { _ in
            @Autowired var repository: SeedRepository
            return DefaultFetchSeedStatsUseCase(repository: repository)
        }
        
        container.register(
            type: FetchBookDetailUseCase.self
        ) { _ in
            @Autowired var repository: BookRepository
            return DefaultFetchBookDetailUseCase(repository: repository)
        }
        
        container.register(
            type: FetchMyLibraryUseCase.self
        ) { _ in
            @Autowired var repository: BookRepository
            return DefaultFetchMyLibraryUseCase(repository: repository)
        }
        
        container.register(
            type: WithdrawAccountUseCase.self
        ) { _ in
            @Autowired var repository: AuthRepository
            return DefautWithdrawAccountUseCase(repository: repository)
        }
        
        container.register(
            type: PatchRecordUseCase.self
        ) { _ in
            @Autowired var repository: RecordRepository
            return DefaultPatchRecordUseCase(repository: repository)
        }
        
        container.register(
            type: DeleteRecordUseCase.self
        ) { _ in
            @Autowired var repository: RecordRepository
            return DefaultDeleteRecordUseCase(repository: repository)
        }
        
        container.register(
            type: DeleteBookUseCase.self
        ) { _ in
            @Autowired var repository: BookRepository
            return DefaultDeleteBookUseCase(repository: repository)
        }

        container.register(
            type: SyncFCMTokenUseCase.self
        ) { _ in
            @Autowired var pushTokenRepository: PushTokenRepository
            @Autowired var notificationRepository: NotificationRepository
            return DefaultSyncFCMTokenUseCase(
                pushTokenRepository: pushTokenRepository,
                notificationRepository: notificationRepository
            )
        }

        container.register(
            type: UpdateNotificationSettingsUseCase.self
        ) { _ in
            @Autowired var notificationRepository: NotificationRepository
            return DefaultUpdateNotificationSettingsUseCase(
                notificationRepository: notificationRepository
            )
        }
    }
}

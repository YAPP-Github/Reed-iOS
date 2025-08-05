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
            return DefaultAppVersionUseCase()
        }
        
        container.register(
            type: FetchRecentSearchUseCase.self
        ) { _ in
            @Autowired var repository: RecentSearchRepository
            return DefaultFetchRecentSearchUseCase(repository: repository)
        }
        
        container.register(
            type: SearchBookUseCase.self,
            name: "Library"
        ) { _ in
            @Autowired var repository: BookRepository
            return LibrarySearchBookUseCase(repository: repository)
        }
        
        // Global RecentSearch UseCases
        container.register(
            type: FetchRecentSearchUseCase.self,
            name: "Global"
        ) { _ in
            @Autowired(name: "Global") var repository: RecentSearchRepository
            return DefaultFetchRecentSearchUseCase(repository: repository)
        }

        container.register(
            type: StoreRecentSearchUseCase.self,
            name: "Global"
        ) { _ in
            @Autowired(name: "Global") var repository: RecentSearchRepository
            return DefaultStoreRecentSearchUseCase(repository: repository)
        }

        container.register(
            type: DeleteRecentSearchUseCase.self,
            name: "Global"
        ) { _ in
            @Autowired(name: "Global") var repository: RecentSearchRepository
            return DefaultDeleteRecentSearchUseCase(repository: repository)
        }

        // Library RecentSearch UseCases
        container.register(
            type: FetchRecentSearchUseCase.self,
            name: "Library"
        ) { _ in
            @Autowired(name: "Library") var repository: RecentSearchRepository
            return DefaultFetchRecentSearchUseCase(repository: repository)
        }

        container.register(
            type: StoreRecentSearchUseCase.self,
            name: "Library"
        ) { _ in
            @Autowired(name: "Library") var repository: RecentSearchRepository
            return DefaultStoreRecentSearchUseCase(repository: repository)
        }

        container.register(
            type: DeleteRecentSearchUseCase.self,
            name: "Library"
        ) { _ in
            @Autowired(name: "Library") var repository: RecentSearchRepository
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
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine
import Foundation
import UIKit

public final class AppCoordinator: Coordinator, AuthenticationRequiredNotifying {
    public weak var parentCoordinator: Coordinator?
    public var childCoordinators = [Coordinator]()
    public var navigationController: UINavigationController
    
    private let authStateUseCase: AuthStateUseCase
    private let onboardingCheckUseCase: OnboardingCheckUseCase
    private let markOnboardingSeenUseCase: MarkOnboardingSeenUseCase
    private var cancellable: Set<AnyCancellable> = []
    
    public init(
        navigationController: UINavigationController,
        authStateUseCase: AuthStateUseCase,
        onboardingCheckUseCase: OnboardingCheckUseCase,
        markOnboardingSeenUseCase: MarkOnboardingSeenUseCase
    ) {
        self.navigationController = navigationController
        self.authStateUseCase = authStateUseCase
        self.onboardingCheckUseCase = onboardingCheckUseCase
        self.markOnboardingSeenUseCase = markOnboardingSeenUseCase
    }
    
    public func start() {
        proceedWithAppFlow()
    }
    
    func notifyAuthenticationRequired(onFinish: (() -> Void)?) {
        presentAuthFlow(animated: true, onFinishAuth: onFinish)
    }
    
    private func proceedWithAppFlow() {
        onboardingCheckUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] didSeeOnboarding in
                if didSeeOnboarding {
                    self?.checkAuthAndRoute()
                } else {
                    self?.startOnboardingFlow()
                }
            }
            .store(in: &cancellable)
    }

}

private extension AppCoordinator {
    func startAuthFlow() {
        let loginCoordinator = LoginCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        
        loginCoordinator.onFinish = { [weak self] in
            guard let self else { return }
            authStateUseCase.execute()
                .receive(on: DispatchQueue.main)
                .map(\.termsAgreed)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure = completion {
                            self.startAuthFlow()
                        }
                    },
                    receiveValue: { termsAgreed in
                        if termsAgreed {
                            self.startMainFlow()
                        } else {
                            self.startTermsFlow()
                        }
                    }
                )
                .store(in: &cancellable)
        }
        
        addChildCoordinator(loginCoordinator)
        loginCoordinator.start()
    }
    
    func startMainFlow() {
        let tabBarCoordinator = TabBarCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        
        tabBarCoordinator.onFinish = { [weak self] in
            self?.startAuthFlow()
        }
        
        addChildCoordinator(tabBarCoordinator)
        tabBarCoordinator.start()
    }
    
    func startTermsFlow() {
        let termsCoordinator = TermsCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        
        termsCoordinator.onFinish = { [weak self] in
            self?.startMainFlow()
        }
        
        addChildCoordinator(termsCoordinator)
        termsCoordinator.start()
    }
    
    func startOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        onboardingCoordinator.onFinish = { [weak self] in
            self?.markOnboardingSeenUseCase.execute()
            self?.checkAuthAndRoute()
        }
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    func checkAuthAndRoute() {
        authStateUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.startAuthFlow()
                }
            }, receiveValue: { [weak self] userProfile in
                guard let self else { return }
                if userProfile.termsAgreed {
                    self.startMainFlow()
                } else {
                    self.startTermsFlow()
                }
            })
            .store(in: &cancellable)
    }
}

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
                guard let self else { return }
                if didSeeOnboarding {
                    self.startMainFlow()
                    self.checkAuthAndRoute()
                } else {
                    self.startOnboardingFlow()
                }
            }
            .store(in: &cancellable)
    }
    
    private func presentAuthFlow(
        animated: Bool,
        onFinishAuth: (() -> Void)?
    ) {
        let authNavigationController = UINavigationController()
        let loginCoordinator = LoginCoordinator(
            parentCoordinator: self,
            navigationController: authNavigationController
        )

        loginCoordinator.onFinish = { [weak self] in
            guard let self else { return }
            
            self.navigationController.dismiss(animated: animated)
            AccessModeCenter.shared.mode.send(.member)
            self.checkAuthAndRoute()
            onFinishAuth?()
        }

        addChildCoordinator(loginCoordinator)
        loginCoordinator.start()
        
        navigationController.present(authNavigationController, animated: animated)
    }
    
    private func startMainFlow() {
        let tabBarCoordinator = TabBarCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )

        addChildCoordinator(tabBarCoordinator)
        tabBarCoordinator.start()
    }
    
    private func transitionToAuthenticatedMain() {
        guard !(navigationController.viewControllers.first is UITabBarController) else { return }
        navigationController.viewControllers.removeAll()
        startMainFlow()
    }
    
    private func startTermsFlow() {
        let termsCoordinator = TermsCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        termsCoordinator.onFinish = { [weak self] in
            AccessModeCenter.shared.mode.send(.member)
            self?.navigationController.dismiss(animated: true)
        }
        addChildCoordinator(termsCoordinator)
        termsCoordinator.start()
    }
    
    private func startOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        onboardingCoordinator.onFinish = { [weak self] in
            guard let self else { return }
            self.markOnboardingSeenUseCase.execute()
            self.startMainFlow()
            self.checkAuthAndRoute()
        }
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    private func checkAuthAndRoute() {
        authStateUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        AccessModeCenter.shared.mode.send(.member)
                    case .failure:
                        AccessModeCenter.shared.mode.send(.guest)
                    }
                },
                receiveValue: { [weak self] userProfile in
                    guard let self else { return }
                    if userProfile.termsAgreed {
                        self.transitionToAuthenticatedMain()
                    } else {
                        self.startTermsFlow()
                    }
                }
            )
            .store(in: &cancellable)
    }
}

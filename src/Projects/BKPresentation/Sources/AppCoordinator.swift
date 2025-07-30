// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine
import Foundation
import UIKit

public final class AppCoordinator: Coordinator {
    public weak var parentCoordinator: Coordinator?
    public var childCoordinators = [Coordinator]()
    public var navigationController: UINavigationController
    
    private let authStateUseCase: AuthStateUseCase
    private let onboardingCheckUseCase: OnboardingCheckUseCase
    private var cancellable: Set<AnyCancellable> = []
    
    public init(
        navigationController: UINavigationController,
        authStateUseCase: AuthStateUseCase,
        onboardingCheckUseCase: OnboardingCheckUseCase
    ) {
        self.navigationController = navigationController
        self.authStateUseCase = authStateUseCase
        self.onboardingCheckUseCase = onboardingCheckUseCase
    }
    
    public func start() {
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
            self?.startMainFlow()
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
    
    func startOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        onboardingCoordinator.onFinish = { [weak self] in
            self?.checkAuthAndRoute()
        }
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    func checkAuthAndRoute() {
        authStateUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.startMainFlow()
                case .failure:
                    self?.startAuthFlow()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellable)
    }
}

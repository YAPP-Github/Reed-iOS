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
    private var cancellable: Set<AnyCancellable> = []
    
    public init(
        navigationController: UINavigationController,
        authStateUseCase: AuthStateUseCase
    ) {
        self.navigationController = navigationController
        self.authStateUseCase = authStateUseCase
    }
    
    public func start() {
        authStateUseCase.execute()
            .sink { [weak self] isLoggedIn in
                if isLoggedIn {
                    self?.startMainFlow()
                } else {
                    self?.startAuthFlow()
                }
            }
            .store(in: &cancellable)
    }
    
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
        let mainFlowCoordinator = MainFlowCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        // addChildCoordinator(mainFlowCoordinator)
        mainFlowCoordinator.start()
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit

final class TabBarCoordinator: Coordinator, AuthenticationRequiredNotifying {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private let tabBarController = BottomTabBarController()
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        setupTabBarCoordinators()
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
    func notifyAuthenticationRequired(onFinish: (() -> Void)?) {
        (parentCoordinator as? AuthenticationRequiredNotifying)?.notifyAuthenticationRequired(onFinish: onFinish)
    }
}

private extension TabBarCoordinator {
    func setupTabBarCoordinators() {
        let viewControllers: [UINavigationController] = TabItem.allCases.map { item in
            let navigationController = UINavigationController()
            let coordinator = item.makeCoordinator(
                parent: self, 
                navigationController: navigationController
            )

            addChildCoordinator(coordinator)
            coordinator.start()
            
            navigationController.tabBarItem = UITabBarItem(
                title: item.title,
                image: item.icon.withTintColor(.bkBackgroundColor(.disable)),
                selectedImage: item.icon.withTintColor(.bkContentColor(.primary))
            )
            
            return navigationController
        }

        tabBarController.viewControllers = viewControllers
    }
}

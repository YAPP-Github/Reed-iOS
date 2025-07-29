// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit

final class TabBarCoordinator: Coordinator, FinishNotifying {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var onFinish: (() -> Void)?
    
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
}

private extension TabBarCoordinator {
    func setupTabBarCoordinators() {
        let viewControllers: [UINavigationController] = TabItem.allCases.map { item in
            let navController = UINavigationController()
            let coordinator = item.makeCoordinator(parent: self, navigationController: navController)

            addChildCoordinator(coordinator)
            coordinator.start()
            
            navController.tabBarItem = UITabBarItem(
                title: item.title,
                image: item.icon.withTintColor(.bkBackgroundColor(.disable)),
                selectedImage: item.icon.withTintColor(.bkContentColor(.primary))
            )
            return navController
        }

        tabBarController.viewControllers = viewControllers
    }
    
    func setTabItem(_ item: TabItem) -> UITabBarItem {
        return UITabBarItem(
            title: item.title,
            image: item.icon.withTintColor(.bkBackgroundColor(.disable)),
            selectedImage: item.icon.withTintColor(.bkContentColor(.primary))
        )
    }
}

extension TabBarCoordinator: SessionExpirationHandling {
    func handleSessionExpired() {
        didFinish()
    }
}

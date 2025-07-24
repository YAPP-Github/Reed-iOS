// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit

final class TabBarCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private let tabBarController: BottomTabBarController
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.tabBarController = BottomTabBarController()
    }
    
    func start() {
        setupTabBarCoordinators()
        navigationController.pushViewController(tabBarController, animated: true)
    }
    
    private func setupTabBarCoordinators() {
        var viewControllers: [UINavigationController] = []
        
        let homeNavigationController = UINavigationController()
        let homeCoordinator = MainFlowCoordinator(
            parentCoordinator: self,
            navigationController: homeNavigationController)
        
        addChildCoordinator(homeCoordinator)
        homeCoordinator.start()
        
        homeNavigationController.tabBarItem = setTabItem(.home)
        viewControllers.append(homeNavigationController)
        
        let archiveNavigationController = UINavigationController()
        let archiveCoordinator = ArchiveCoordinator(
            parentCoordinator: self,
            navigationController: archiveNavigationController
        )
        
        addChildCoordinator(archiveCoordinator)
        archiveCoordinator.start()
        
        archiveNavigationController.tabBarItem = setTabItem(.archive)
        viewControllers.append(archiveNavigationController)
        
        tabBarController.viewControllers = viewControllers
    }
    
    
    private func setTabItem(_ item: TabItem) -> UITabBarItem {
        return UITabBarItem(
            title: item.title,
            image: item.icon.withTintColor(.bkBackgroundColor(.disable)),
            selectedImage: item.icon.withTintColor(.bkContentColor(.primary))
        )
    }
    
}

extension TabBarCoordinator {
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}

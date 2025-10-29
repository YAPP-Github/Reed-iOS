// Copyright © 2025 Booket. All rights reserved

import UIKit

final class NotificationSettingsCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        let notificationViewController = NotificationSettingsViewController(
            viewModel: NotificationSettingsViewModel()
        )
        notificationViewController.coordinator = self
        navigationController.pushViewController(notificationViewController, animated: true)
    }
}

extension NotificationSettingsCoordinator: URLPresenting {}

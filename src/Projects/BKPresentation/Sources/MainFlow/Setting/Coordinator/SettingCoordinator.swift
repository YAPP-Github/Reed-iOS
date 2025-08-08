// Copyright © 2025 Booket. All rights reserved

import UIKit

final class SettingCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
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
        let settingViewController = SettingViewController(viewModel: SettingViewModel())
        settingViewController.coordinator = self
        navigationController.pushViewController(settingViewController, animated: true)
    }
}

extension SettingCoordinator: SessionExpirationNotifying, ErrorHandleable, WebPresenting {}

// Copyright © 2025 Booket. All rights reserved

import UIKit

final class SearchCoordinator: Coordinator {
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
        let searchViewController = SearchViewController(viewModel: SearchViewModel())
        searchViewController.coordinator = self
        navigationController.pushViewController(searchViewController, animated: true)
    }
}

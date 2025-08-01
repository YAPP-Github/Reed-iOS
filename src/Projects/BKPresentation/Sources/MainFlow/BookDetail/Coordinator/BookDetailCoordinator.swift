// Copyright © 2025 Booket. All rights reserved

import UIKit

final class BookDetailCoordinator: Coordinator {
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
        let viewController = BookDetailViewController(viewModel: BookDetailViewModel())
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
}

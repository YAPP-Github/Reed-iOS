// Copyright © 2025 Booket. All rights reserved

import UIKit
import Foundation

final class NoteCoordinator: Coordinator, SessionExpirationNotifying {
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
        let viewController = NoteViewController(viewModel: NoteViewModel())
        viewController.delegate = self
        navigationController.pushViewController(viewController, animated: true)
    }
}

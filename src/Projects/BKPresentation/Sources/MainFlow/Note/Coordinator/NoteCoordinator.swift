// Copyright © 2025 Booket. All rights reserved

import UIKit

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
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension NoteCoordinator {
    func didCompleteNoteCreation() {
        let viewController = NoteCompletionViewController()
        let noteNavigationController = UINavigationController(rootViewController: viewController)
        noteNavigationController.modalPresentationStyle = .fullScreen
        navigationController.present(noteNavigationController, animated: true) {
            self.popAndFinish()
        }
    }
}

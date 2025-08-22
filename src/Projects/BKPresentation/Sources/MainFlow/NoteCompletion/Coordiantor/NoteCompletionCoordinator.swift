// Copyright © 2025 Booket. All rights reserved

import BKDomain
import UIKit

final class NoteCompletionCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    private let recordId: String
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController,
        recordId: String
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.recordId = recordId
    }
    
    func start() {
        let viewController = NoteCompletionViewController(
            viewModel: NoteCompletionViewModel(recordId: recordId),
            recordId: recordId
        )
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }
}

extension NoteCompletionCoordinator: AuthenticationRequiredNotifying, ErrorHandleable {
    func notifyAuthenticationRequired(onFinish: (() -> Void)?) {
        (parentCoordinator as? AuthenticationRequiredNotifying)?.notifyAuthenticationRequired(onFinish: onFinish)
    }
}

extension NoteCompletionCoordinator {
    func goToShareView(item: BookDetailItem) {
        let vc = SentenceCardViewController(viewModel: SentenceCardViewModel(item))
        if let bookDetail = parentCoordinator as? BookDetailCoordinator {
            vc.coordinator = bookDetail
        } else if let note = parentCoordinator as? NoteCoordinator,
                  let bookDetail = note.parentCoordinator as? BookDetailCoordinator {
            vc.coordinator = bookDetail
        }

        navigationController.pushViewController(vc, animated: true)
    }

    func didTapEditButton(recordId: String) {
        let editNC = UINavigationController()
        editNC.modalPresentationStyle = .fullScreen

        let editCoordinator = NoteEditCoordinator(
            parentCoordinator: self,
            navigationController: editNC,
            recordId: recordId
        )
        addChildCoordinator(editCoordinator)
        editCoordinator.start()

        topPresenter().present(editNC, animated: true)
    }
}

private extension NoteCompletionCoordinator {
    func topPresenter() -> UIViewController {
        var base: UIViewController = navigationController
        while let presented = base.presentedViewController {
            base = presented
        }
        return base
    }
}

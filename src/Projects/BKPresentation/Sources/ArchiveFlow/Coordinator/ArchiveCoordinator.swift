// Copyright © 2025 Booket. All rights reserved

import UIKit

final class ArchiveCoordinator: Coordinator {
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
        let archiveViewController = ArchiveViewController(viewModel: ArchiveViewModel())
        archiveViewController.coordinator = self
        navigationController.pushViewController(archiveViewController, animated: false)
    }
}

extension ArchiveCoordinator: AuthenticationRequiredNotifying, ErrorHandleable {
    func notifyAuthenticationRequired(onFinish: (() -> Void)?) {
        (parentCoordinator as? AuthenticationRequiredNotifying)?.notifyAuthenticationRequired(onFinish: onFinish)
    }
}

extension ArchiveCoordinator {
    func didTapSearchButton() {
        let searchCoordinator = SearchCoordinator(
            parentCoordinator: self,
            navigationController: navigationController,
            searchViewType: .myLibrarySearch
        )
        searchCoordinator.start()
        childCoordinators.append(searchCoordinator)
    }
    
    func didTapSettingButton() {
        let settingCoordinator = SettingCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        childCoordinators.append(settingCoordinator)
        settingCoordinator.start()
    }
    
    func didTapBookDetailButton(
        isbn: String,
        userBookId: String
    ) {
        let bookDetailCoordinator = BookDetailCoordinator(
            parentCoordinator: self,
            navigationController: navigationController,
            isbn: isbn,
            userBookId: userBookId
        )
        childCoordinators.append(bookDetailCoordinator)
        bookDetailCoordinator.start()
    }
}

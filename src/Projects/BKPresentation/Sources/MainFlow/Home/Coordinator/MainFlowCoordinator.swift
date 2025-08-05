// Copyright © 2025 Booket. All rights reserved

import Foundation
import UIKit

final class MainFlowCoordinator: Coordinator, FinishNotifying {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var onFinish: (() -> Void)?
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        let homeViewController = HomeViewController(viewModel: HomeViewModel())
        homeViewController.coordinator = self
        navigationController.pushViewController(homeViewController, animated: true)
    }
}

extension MainFlowCoordinator {
    func didTapSettingButton() {
        let settingCoordinator = SettingCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        childCoordinators.append(settingCoordinator)
        settingCoordinator.start()
    }
    
    func didTapSearchButton() {
        let searchCoordinator = SearchCoordinator(
            parentCoordinator: self,
            navigationController: navigationController,
            searchViewType: .globalSearch
        )
        childCoordinators.append(searchCoordinator)
        searchCoordinator.start()
    }
    
    func didTapNoteButton(bookId: String) {
        let noteCoordinator = NoteCoordinator(
            parentCoordinator: self,
            navigationController: navigationController,
            bookId: bookId
        )
        childCoordinators.append(noteCoordinator)
        noteCoordinator.start()
    }
    
    func didTapBookDetailButton() {
        let bookDetailCoordinator = BookDetailCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        childCoordinators.append(bookDetailCoordinator)
        bookDetailCoordinator.start()
    }
}

// Copyright © 2025 Booket. All rights reserved

import UIKit

final class SearchCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private let searchViewType: SearchViewType
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController,
        searchViewType: SearchViewType
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.searchViewType = searchViewType
    }
    
    func start() {
        let searchViewController = SearchViewController(
            viewModel: SearchViewModel(searchViewType: searchViewType)
        )
        searchViewController.coordinator = self
        navigationController.pushViewController(searchViewController, animated: true)
    }
}

extension SearchCoordinator {
    func didBookRegistered(bookId: String) {
        let noteCoordinator = NoteCoordinator(
            parentCoordinator: self,
            navigationController: navigationController,
            bookId: bookId
        )
        addChildCoordinator(noteCoordinator)
        noteCoordinator.start()
    }
}

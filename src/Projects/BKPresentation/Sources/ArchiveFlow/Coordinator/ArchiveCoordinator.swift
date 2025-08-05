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

extension ArchiveCoordinator {
    // Archive 관련 네비게이션 메서드들을 여기에 추가
    func didTapSearchButton() {
        let searchCoordinator = SearchCoordinator(
            parentCoordinator: self,
            navigationController: navigationController,
            searchViewType: .myLibrarySearch
        )
        searchCoordinator.start()
        childCoordinators.append(searchCoordinator)
    }
}

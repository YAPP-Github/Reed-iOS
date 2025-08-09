// Copyright © 2025 Booket. All rights reserved

import UIKit

final class BookDetailCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private let isbn: String
    private let userBookId: String
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController,
        isbn: String,
        userBookId: String
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.isbn = isbn
        self.userBookId = userBookId
    }
    
    func start() {
        let viewController = BookDetailViewController(
            viewModel: BookDetailViewModel(
                isbn: isbn,
                userBookId: userBookId
            )
        )
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension BookDetailCoordinator: SessionExpirationNotifying, ErrorHandleable {}

extension BookDetailCoordinator {
    func didTapAddNoteButton(bookId: String) {
        let noteCoordinator = NoteCoordinator(
            parentCoordinator: self,
            navigationController: navigationController,
            bookId: bookId
        )
        addChildCoordinator(noteCoordinator)
        noteCoordinator.start()
    }
    
    func didTapCell(recordId: String) {
        print("\(recordId)로 화면 이동")
//        let noteCompletionViewModel = NoteCompletionViewModel(recordId: recordId)
//        let noteCompletionViewController = NoteCompletionViewController(viewModel: noteCompletionViewModel)
//        let navigationController = UINavigationController(rootViewController: noteCompletionViewController)
//        self.navigationController.present(navigationController, animated: true)
    }
}

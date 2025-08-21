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

extension BookDetailCoordinator: AuthenticationRequiredNotifying, ErrorHandleable {
    func notifyAuthenticationRequired(onFinish: (() -> Void)?) {
        (parentCoordinator as? AuthenticationRequiredNotifying)?.notifyAuthenticationRequired(onFinish: onFinish)
    }
}

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
        let viewController = NoteCompletionViewController(
            viewModel: NoteCompletionViewModel(recordId: recordId)
        )
        let noteNavigationController = UINavigationController(rootViewController: viewController)

        noteNavigationController.modalPresentationStyle = .fullScreen
        navigationController.present(noteNavigationController, animated: true)
    }
    
    /// 문장 카드 확인 및 공유하기 화면으로 이동합니다.
    func goToShareView(item: BookDetailItem) {
        let viewController = SentenceCardViewController(
            viewModel: SentenceCardViewModel(item)
        )
        viewController.coordinator = self
        
        navigationController.pushViewController(viewController, animated: true)
    }
}


// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import BKDomain
import Combine
import UIKit

final class SearchCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private let searchViewType: SearchViewType
    private var cancellables = Set<AnyCancellable>()
    
    @Autowired var openExternalLinkUseCase: OpenExternalLinkUseCase
    
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
            viewModel: SearchViewModel(
                searchViewType: searchViewType
            )
        )
        searchViewController.coordinator = self
        navigationController.pushViewController(searchViewController, animated: true)
    }
}

extension SearchCoordinator: ErrorHandleable, AuthenticationRequiredNotifying {
    func notifyAuthenticationRequired(onFinish: (() -> Void)?) {
        (parentCoordinator as? AuthenticationRequiredNotifying)?.notifyAuthenticationRequired(onFinish: onFinish)
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
    
    func didTapBookDetail(isbn: String, userBookId: String) {
        let bookDetailCoordinator = BookDetailCoordinator(
            parentCoordinator: self,
            navigationController: navigationController,
            isbn: isbn,
            userBookId: userBookId
        )
        addChildCoordinator(bookDetailCoordinator)
        bookDetailCoordinator.start()
    }
    
    func showRequestPage() {
        let webURL = URLConstants.kakaoChatURL
        let appScheme = URLConstants.kakaoAppScheme
        
        Log.debug("외부 링크 오픈 시도 - Web: \(webURL), App: \(appScheme)", logger: AppLogger.ui)
        
        openExternalLinkUseCase.execute(urlString: webURL, appScheme: appScheme)
            .receive(on: DispatchQueue.main)
            .sink { success in
                if success {
                    Log.debug("외부 링크 오픈 성공", logger: AppLogger.ui)
                } else {
                    Log.error("외부 링크 오픈 실패 (URL 스킴 확인 필요)", logger: AppLogger.ui)
                }
            }
            .store(in: &cancellables)
    }
}

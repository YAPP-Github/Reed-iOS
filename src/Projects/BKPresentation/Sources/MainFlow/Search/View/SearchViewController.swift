// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import Combine
import UIKit

enum SearchViewEvent: Equatable {
    case search(String)
    case loadNextPage
    case deleteRecentQuery(String)
    case upsertBook(String)
}

final class SearchViewController: BaseViewController<SearchView> {
    weak var coordinator: SearchCoordinator?
    
    override var bkNavigationTitle: String {
        return "도서 검색"
    }
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        return .standard(viewController: self)
    }
    
    private var cancellable = Set<AnyCancellable>()
    let viewModel: AnyViewBindableViewModel<SearchViewModel.State, SearchViewModel.Action>
    
    private struct Snapshot: Equatable {
        let state: SearchViewModel.SearchState
        let count: Int
    }
    
    init(viewModel: SearchViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func bindAction() {
        viewModel.send(.onAppear)
        
        contentView.eventPublisher
            .compactMap { event -> String? in
                if case let .search(query) = event { return query }
                return nil
            }
            .removeDuplicates()
            .sink { [weak self] query in
                self?.viewModel.send(.search(query))
            }
            .store(in: &cancellable)
        
        contentView.eventPublisher
            .filter { $0 == .loadNextPage }
            .sink { [weak self] _ in
                self?.viewModel.send(.loadNextPage)
            }
            .store(in: &cancellable)
        
        contentView.eventPublisher
            .compactMap { event -> String? in
                if case let .deleteRecentQuery(query) = event { return query }
                return nil
            }
            .removeDuplicates()
            .sink { [weak self] query in
                self?.viewModel.send(.deleteRecentQuery(query))
            }
            .store(in: &cancellable)
        
        contentView.eventPublisher
            .compactMap { event -> String? in
                if case let .upsertBook(isbn) = event { return isbn }
                return nil
            }
            .removeDuplicates()
            .sink { [weak self] query in
                self?.presentBookRegistration(with: query)
            }
            .store(in: &cancellable)
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { state in
                Snapshot(
                    state: state.searchState,
                    count: state.totalResults
                )
            }
            .removeDuplicates()
            .sink { [weak self] snapshot in
                self?.contentView.applySnapshot(
                    with: snapshot.state,
                    count: snapshot.count
                )
            }
            .store(in: &cancellable)
    }
}

private extension SearchViewController {
    func presentBookRegistration(with isbn: String) {
        let statusView = BookRegistrationStatusView()
        let sheet = BKBottomSheetViewController(
            title: "등록 옵션",
            style: .leadingCloseButton,
            suppliedContentStyle: .lower(statusView),
            buttonConfiguration: .singleFullButton() { [weak self] in
                guard let selected = statusView.selectedStatus else { return }
                self?.handleRegistrationSelection(status: selected, isbn: isbn)
            }
        )
        
        sheet.show(from: self, animated: true)
    }
    
    func handleRegistrationSelection(status: BookRegistrationStatus, isbn: String) {
        Log.debug("선택된 책: \(isbn), 상태: \(status.rawValue)", logger: AppLogger.ui)
//        viewModel.send(.upsertBook(isbn))
    }
}

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
            .throttle(for: .milliseconds(800), scheduler: RunLoop.main, latest: false)
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
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates { $0.noteReadied == $1.noteReadied }
            .filter { $0.noteReadied }
            .compactMap { $0.bookId }
            .sink { [weak self] bookId in
                self?.coordinator?.didBookRegistered(bookId: bookId)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map(\.error)
            .removeDuplicates()
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.coordinator?.handleError(error)
                self?.viewModel.send(.errorHandled)
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
            buttonConfiguration: .singleFullButton(
                title: "도서 등록"
            ) { [weak self] in
                guard let selected = statusView.selectedStatus else { return }
                self?.dismiss(animated: true)
                self?.handleRegistrationSelection(status: selected, isbn: isbn)
            }
        )
        sheet.button?.primaryButton?.isEnabled = false
        statusView.onSelected = {
            sheet.button?.primaryButton?.isEnabled = true
        }
        sheet.show(from: self, animated: true)
    }
    
    func handleRegistrationSelection(
        status: BookRegistrationStatus,
        isbn: String
    ) {
        viewModel.send(.upsertBook(isbn: isbn, status: status))
        presentNoteSuggestion(with: isbn)
    }
    
    func presentNoteSuggestion(with isbn: String) {
        // TODO: - 그래픽 디자인 작업 이후 변경
        let graphic = BKImage.Graphics.empty
        let graphicView = UIImageView(image: graphic)
        let sheet = BKBottomSheetViewController(
            title: "도서가 등록되었어요!",
            subtitle: "독서 기록을 시작할까요?",
            style: .centered,
            suppliedContentStyle: .upper(graphicView),
            buttonConfiguration: .twoButtonGroup(
                leftTitle: "아니요, 나중에요",
                rightTitle: "네, 시작할게요!",
                leftAction: { [weak self] in
                    self?.dismiss(animated: true)
                },
                rightAction: { [weak self] in
                    self?.dismiss(animated: true)
                    self?.viewModel.send(.loadNoteFlow)
                }
            )
        )
        
        sheet.show(from: self, animated: true)
    }
}

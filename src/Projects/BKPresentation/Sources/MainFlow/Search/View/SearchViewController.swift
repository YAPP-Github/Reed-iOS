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
    case goToBookDetail(isbn: String, userBookId: String)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        viewModel.send(.onAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func bindAction() {
        contentView.eventPublisher
            .compactMap { event -> String? in
                if case let .search(query) = event { return query }
                return nil
            }
            .throttle(for: .milliseconds(250), scheduler: RunLoop.main, latest: false)
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
            
        contentView.eventPublisher
            .compactMap { event -> (String, String)? in
                if case let .goToBookDetail(isbn, userBookId) = event { return (isbn, userBookId) }
                return nil
            }
            .throttle(for: .milliseconds(800), scheduler: RunLoop.main, latest: false)
            .sink { [weak self] (isbn, userBookId) in
                self?.coordinator?.didTapBookDetail(isbn: isbn, userBookId: userBookId)
            }
            .store(in: &cancellable)
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { $0.searchBarPlaceholder }
            .removeDuplicates()
            .sink { [weak self] placeholder in
                self?.contentView.setSearchBarPlaceholder(with: placeholder)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { $0.searchViewTitle }
            .removeDuplicates()
            .sink { [weak self] title in
                self?.navigationItem.title = title
            }
            .store(in: &cancellable)
        
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
            .compactMap { $0.isUpserted }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isbn in
                self?.presentNoteSuggestion(with: isbn)
                self?.viewModel.send(.noteSuggestionShown)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map { $0.isLoading }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }            
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
        
        viewModel.statePublisher
            .map(\.isRetrying)
            .removeDuplicates()
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.coordinator?.presentCustomErrorAlert(
                    subtitle: """
                    일시적인 오류로 
                    데이터를 불러올 수 없어요
                    """,
                    confirmTitle: "다시 시도하기",
                    onConfirm: { [weak self] in
                        self?.viewModel.send(.retryTapped)
                    }
                )
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map(\.isReRetrying)
            .removeDuplicates()
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.coordinator?.presentCustomErrorAlert(
                    subtitle: """
                    일시적인 오류로 데이터를 불러올 수 없어요.
                    잠시 후 다시 시도해주세요
                    """,
                    confirmTitle: "확인",
                    onConfirm: {}
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
    }
    
    func presentNoteSuggestion(with isbn: String) {
        let graphic = BKImage.Graphics.coinCheck
        let graphicView = UIImageView(image: graphic)
        graphicView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 120, height: 120))
        }
        let sheet = BKBottomSheetViewController(
            title: "도서가 등록되었어요!",
            subtitle: "독서 기록을 바로 시작할까요?",
            style: .centered,
            suppliedContentStyle: .upper(graphicView),
            buttonConfiguration: .twoButtonGroup(
                leftTitle: "나중에 하기",
                rightTitle: "기록 시작하기",
                leftAction: { [weak self] in
                    self?.dismiss(animated: true)
                    self?.hideLoading()
                },
                rightAction: { [weak self] in
                    self?.dismiss(animated: true)
                    self?.viewModel.send(.loadNoteFlow)
                    self?.hideLoading()
                }
            )
        )
        
        sheet.show(from: self, animated: true)
    }
}

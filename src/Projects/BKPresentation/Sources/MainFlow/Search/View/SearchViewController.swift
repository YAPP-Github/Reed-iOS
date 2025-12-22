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

final class SearchViewController: BaseViewController<SearchView>, ScreenLoggable {
    var screenName: String = ""

    weak var coordinator: SearchCoordinator?
    
    override var bkNavigationTitle: String {
        return ""
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
        
        viewModel.send(.onAppearWithoutReset)
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
            .map { $0.viewType }
            .removeDuplicates()
            .sink { [weak self] type in
                switch type {
                case .defaultSearch:
                    self?.logScreenView(name: GATracking.SearchAndRegister.start)
                case .myLibrarySearch:
                    self?.logScreenView(name: GATracking.HomeAndLibrary.searchBook)
                default:
                    return
                }
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
                self?.logScreenView(name: GATracking.SearchAndRegister.result)
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
            .compactMap { state -> (isbn: String, status: BookRegistrationStatus)? in
                guard let isbn = state.isUpserted,
                      let status = state.selectedStatus else {
                    return nil
                }
                return (isbn, status)
            }
            .removeDuplicates { previous, current in
                return previous.isbn == current.isbn && previous.status == current.status
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (isbn, status) in
                self?.presentNoteSuggestion(with: isbn, status: status)
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
//                self?.logScreenView(name: GATracking.Error.search)
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
//                self?.logScreenView(name: GATracking.Error.search)

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
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { state -> (isEmpty: Bool, viewType: SearchViewType) in
                if case .result(let resultState) = state.searchState {
                    let isEmpty = resultState.books.isEmpty && resultState.bookInfos.isEmpty
                    return (isEmpty, state.viewType ?? .defaultSearch)
                }
                return (false, state.viewType ?? .defaultSearch)
            }
            .removeDuplicates { prev, curr in
                return prev.isEmpty == curr.isEmpty && prev.viewType == curr.viewType
            }
            .sink { [weak self] (isEmpty, viewType) in
                guard let self = self else { return }
                
                if isEmpty {
                    let emptyView = self.makeEmptyView(for: viewType)
                    self.contentView.updateEmptyView(with: emptyView)
                } else {
                    self.contentView.updateEmptyView(with: nil)
                }
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
                self?.logScreenView(name: GATracking.SearchAndRegister.selectOption)
                
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
    
    func presentNoteSuggestion(with isbn: String, status: BookRegistrationStatus) {
        let graphic = BKImage.Graphics.coinCheck
        let graphicView = UIImageView(image: graphic)
        graphicView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 120, height: 120))
        }
        
        let sheetTitle = "도서가 등록되었어요!"
        let cancelAction : (() -> Void)? = { [weak self] in
            self?.dismiss(animated: true)
            self?.hideLoading()
        }
        
        let nextAction : (() -> Void)? = { [weak self] in
            self?.dismiss(animated: true)
            self?.viewModel.send(.loadNoteFlow)
            self?.hideLoading()
            
        }
        logScreenView(name: GATracking.SearchAndRegister.complete)
        
        var buttonGroup: BKButtonGroup?
        
        if status == .before {
            buttonGroup = .singleFullButton(
                title: status.getCancelButtonTitle(),
                action: cancelAction
            )
        } else {
            buttonGroup = .twoButtonGroup(
                leftTitle: status.getCancelButtonTitle(),
                rightTitle: status.getNextButtonTitle(),
                leftAction: cancelAction,
                rightAction: nextAction
            )
        }
        
        let sheet = BKBottomSheetViewController(
            title: sheetTitle,
            subtitle: status.getSubTitle(),
            style: .centered,
            suppliedContentStyle: .upper(graphicView),
            buttonConfiguration: buttonGroup
        )
        
        sheet.show(from: self, animated: true)
    }
}

private extension SearchViewController {
    // 뷰 타입에 따라 내용을 다르게 설정하여 SearchEmptyView 반환
    func makeEmptyView(for type: SearchViewType) -> UIView {
        let emptyView = SearchEmptyView()
        
        switch type {
        case .defaultSearch:
            emptyView.setContent(
                title: "검색어와 일치하는 도서가 없습니다.",
                description: "찾으시는 도서가 없다면 직접 등록해보세요.",
                buttonTitle: "도서 등록 요청하기"
            )
            emptyView.onActionButtonTapped = { [weak self] in
                // 뷰모델로 액션 전달
                self?.viewModel.send(.emptyViewButtonTapped)
            }
            
        case .myLibrarySearch:
            emptyView.setContent(
                title: "내 서재에 해당 도서가 없습니다.",
                description: nil, // 설명 없음
                buttonTitle: nil
            )
            emptyView.onActionButtonTapped = { [weak self] in
                self?.viewModel.send(.emptyViewButtonTapped)
            }
        }
        
        return emptyView
    }
}

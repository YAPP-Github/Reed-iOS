// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

final class BookDetailViewModel: BaseViewModel {
    struct State {
        var items: [BookDetailItem] = []
        var currentBook: Book?
        var sortOption: SortOption = .pageDescending
        var seeds = [Seed]()
        var isAddNoteTriggered = false
        var isStatusButtonTriggered = false
        let userBookId: String
        var error: DomainError?
        var isRetrying: Bool = false
        var isCellTapped = false
        var selectedRecordId: String?
        var nextPage: Int = 0
        var hasMore: Bool = true
        var totalResults = 0
        var deleteCompleted: Bool = false
        var isDeletingBook: Bool = false
        var isDeletingRecord: Bool = false
        var shareTriggered: Bool = false
        var shareItem: BookDetailItem?
    }
    
    enum Action {
        case onAppear
        case changeSortOption(SortOption)
        case addNoteButtonTapped
        case addNoteHandled
        case statusButtonTapped
        case changeStatusHandled
        case cellTapped(recordId: String)
        case cellTapHandled
        case upsert(isbn: String, status: BookRegistrationStatus)
        case upsertSuccessed(Book)
        case fetchRecordsSuccessed(items: [BookDetailItem], hasMore: Bool, totalResult: Int)
        case fetchSeedStatsSuccessed([Seed])
        case fetchBookDetailSuccessed(Book)
        case errorOccured(DomainError)
        case errorHandled
        case retryTapped
        case loadNextPage
        case appendRecordsSuccessed(items: [BookDetailItem], hasMore: Bool)
        case deleteBookButtonTapped
        case deleteBookSuccessed
        case deleteRecordButtonTapped(String)
        case deleteRecordSuccessed
        case shareButtonTapped(String)
        case shareHandled
    }
    
    enum SideEffect {
        case upsertBook(isbn: String, status: BookRegistrationStatus)
        case fetchRecords(page: Int)
        case fetchSeedStats
        case fetchBookDetail
        case deleteBook
        case deleteRecord(String)
    }
    
    @Published private var state: State
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    private var lastEffect: SideEffect? = nil
    
    @Autowired private var fetchRecordsUseCase: FetchRecordsUseCase
    @Autowired private var fetchSeedStatsUseCase: FetchSeedStatsUseCase
    @Autowired private var fetchBookDetailUseCase: FetchBookDetailUseCase
    @Autowired private var bookUpsertUseCase: BookUpsertUseCase
    @Autowired private var deleteBookUseCase: DeleteBookUseCase
    @Autowired private var deleteRecordUseCase: DeleteRecordUseCase
    
    private let isbn: String
    
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init(
        isbn: String,
        userBookId: String
    ) {
        self.isbn = isbn
        self.state = State(userBookId: userBookId)
        bindSideEffects()
    }
    
    func send(_ action: Action) {
        let (newState, effects) = reduce(action: action, state: state)
        state = newState
        effects.forEach { sideEffectSubject.send($0) }
    }
    
    // swiftlint:disable cyclomatic_complexity
    func reduce(action: Action, state: State) -> (State, [SideEffect]) {
        var newState = state
        var effects: [SideEffect] = []
        
        switch action {
        case .onAppear:
            effects.append(.fetchBookDetail)
            effects.append(.fetchRecords(page: 0))
            effects.append(.fetchSeedStats)
            
        case .changeSortOption(let option):
            newState.sortOption = option
            
        case .addNoteButtonTapped:
            newState.isAddNoteTriggered = true
            
        case .addNoteHandled:
            newState.isAddNoteTriggered = false
            
        case .statusButtonTapped:
            newState.isStatusButtonTriggered = true
            
        case .changeStatusHandled:
            newState.isStatusButtonTriggered = false
            
        case .upsert(let isbn, let status):
            effects.append(.upsertBook(isbn: isbn, status: status))
            
        case .upsertSuccessed(let book):
            newState.currentBook = book
            
        case .fetchBookDetailSuccessed(let book):
            newState.currentBook = book
            
        case .fetchRecordsSuccessed(let items, let hasMore, let totalResults):
            newState.items = items
            newState.nextPage = 1
            newState.hasMore = hasMore
            newState.totalResults = totalResults
            
        case .fetchSeedStatsSuccessed(let seeds):
            newState.seeds = seeds
            
        case .errorOccured(let error):
            newState.isDeletingBook = false
            newState.isDeletingRecord = false
            if newState.isRetrying == false {
                newState.isRetrying = true
            } else {
                newState.isRetrying = false
                newState.error = error
            }
            
        case .retryTapped:
            if let last = lastEffect {
                effects.append(last)
            }
            
        case .errorHandled:
            newState.error = nil
            
        case .cellTapped(let recordId):
            newState.isCellTapped = true
            newState.selectedRecordId = recordId
            
        case .cellTapHandled:
            newState.isCellTapped = false
            newState.selectedRecordId = nil
            
        case .loadNextPage:
            if newState.hasMore {
                effects.append(.fetchRecords(page: newState.nextPage))
            }
            
        case .appendRecordsSuccessed(let items, let hasMore):
            var existing = Set(newState.items.map(\.recordId))
            let deduped = items.filter { existing.insert($0.recordId).inserted }
            newState.items.append(contentsOf: deduped)
            if hasMore { newState.nextPage += 1 }
            newState.hasMore = hasMore
            
        case .deleteBookButtonTapped:
            newState.isDeletingBook = true
            effects.append(.deleteBook)
            
        case .deleteBookSuccessed:
            newState.isDeletingBook = false
            newState.deleteCompleted = true
            
        case .deleteRecordButtonTapped(let recordId):
            newState.isDeletingRecord = true
            effects.append(.deleteRecord(recordId))
            
        case .deleteRecordSuccessed:
            newState.isDeletingRecord = false
            effects.append(.fetchRecords(page: 0))
            effects.append(.fetchSeedStats)
            
        case .shareButtonTapped(let recordId):
            if let item = newState.items.first(where: { $0.recordId == recordId }) {
                newState.shareTriggered = true
                newState.shareItem = item
            }
            
        case .shareHandled:
            newState.shareTriggered = false
            newState.shareItem = nil
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .upsertBook(let isbn, let status):
            return bookUpsertUseCase.execute(
                isbn: isbn,
                status: status.toBookStatus()
            )
            .map { Action.upsertSuccessed($0.toBook()) }
            .catch { [weak self] in
                self?.lastEffect = .upsertBook(isbn: isbn, status: status)
                return Just(Action.errorOccured($0))
            }
            .eraseToAnyPublisher()
            
        case .fetchBookDetail:
            return fetchBookDetailUseCase.execute(isbn: isbn)
                .map { Action.fetchBookDetailSuccessed($0) }
                .catch { [weak self] in
                    self?.lastEffect = .fetchBookDetail
                    return Just(Action.errorOccured($0))
                }
                .eraseToAnyPublisher()
            
        case .fetchRecords(let page):
            return fetchRecordsUseCase.execute(id: state.userBookId, page: page)
                .map {
                    let items = $0.infos.map { BookDetailItem.from(recordInfo: $0) }
                    return page == 0 ? Action.fetchRecordsSuccessed(
                        items: items,
                        hasMore: $0.hasMore,
                        totalResult: $0.totalCount
                    ) : Action.appendRecordsSuccessed(
                        items: items,
                        hasMore: $0.hasMore
                    )
                }
                .catch { [weak self] in
                    self?.lastEffect = .fetchRecords(page: page)
                    return Just(Action.errorOccured($0))
                }
                .eraseToAnyPublisher()
            
        case .fetchSeedStats:
            return fetchSeedStatsUseCase.execute(id: state.userBookId)
                .map { Action.fetchSeedStatsSuccessed($0) }
                .catch { [weak self] in
                    self?.lastEffect = .fetchSeedStats
                    return Just(Action.errorOccured($0))
                }
                .eraseToAnyPublisher()
                
        case .deleteBook:
            return deleteBookUseCase.execute(bookId: state.userBookId)
                .map { _ in Action.deleteBookSuccessed }
                .catch { [weak self] in
                    self?.lastEffect = .deleteBook
                    return Just(Action.errorOccured($0))
                }
                .eraseToAnyPublisher()
                
        case .deleteRecord(let recordId):
            return deleteRecordUseCase.execute(recordId: recordId)
                .map { _ in Action.deleteRecordSuccessed }
                .catch { [weak self] in
                    self?.lastEffect = .deleteRecord(recordId)
                    return Just(Action.errorOccured($0))
                }
                .eraseToAnyPublisher()
        }
    }
    
    private func bindSideEffects() {
        sideEffectSubject
            .flatMap { [weak self] effect in
                self?.handle(effect) ?? Empty().eraseToAnyPublisher()
            }
            .sink(receiveValue: send(_:))
            .store(in: &cancellables)
    }
}

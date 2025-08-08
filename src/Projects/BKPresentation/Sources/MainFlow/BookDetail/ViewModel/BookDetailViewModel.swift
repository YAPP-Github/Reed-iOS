// Copyright © 2025 Booket. All rights reserved

import Combine
import BKCore
import BKDomain
import Foundation

final class BookDetailViewModel: BaseViewModel {
    struct State {
        var items: [BookDetailItem] = []
        var currentBook: Book? = nil
        var sortOption: SortOption = .pageDescending
        var seeds = [Seed]()
        var isAddNoteTriggered = false
        var isStatusButtonTriggered = false
        let userBookId: String
    }
    
    enum Action {
        case onAppear
        case changeSortOption(SortOption)
        case addNoteButtonTapped
        case addNoteHandled
        case statusButtonTapped
        case changeStatusHandled
        case upsert(isbn: String, status: BookRegistrationStatus)
        case upsertSuccessed(Book)
        case fetchRecordsSuccessed([BookDetailItem])
        case fetchSeedStatsSuccessed([Seed])
        case fetchBookDetailSuccessed(Book)
    }
    
    enum SideEffect {
        case upsertBook(isbn: String, status: BookRegistrationStatus)
        case fetchRecords
        case fetchSeedStats
        case fetchBookDetail
    }
    
    @Published private var state: State
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    @Autowired private var fetchRecordsUseCase: FetchRecordsUseCase
    @Autowired private var fetchSeedStatsUseCase: FetchSeedStatsUseCase
    @Autowired private var fetchBookDetailUseCase: FetchBookDetailUseCase
    @Autowired private var bookUpsertUseCase: BookUpsertUseCase
    
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
    
    func reduce(action: Action, state: State) -> (State, [SideEffect]) {
        var newState = state
        var effects: [SideEffect] = []
        
        switch action {
        case .onAppear:
            effects.append(.fetchBookDetail)
            effects.append(.fetchRecords)
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
            
        case .fetchRecordsSuccessed(let items):
            newState.items = items
            
        case .fetchSeedStatsSuccessed(let seeds):
            newState.seeds = seeds
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
            .catch { _ in Empty() }
            .eraseToAnyPublisher()
            
        case .fetchBookDetail:
            return fetchBookDetailUseCase.execute(isbn: isbn)
                .map { Action.fetchBookDetailSuccessed($0)}
                .catch { _ in Empty() }
                .eraseToAnyPublisher()
            
        case .fetchRecords:
            return fetchRecordsUseCase.execute(id: state.userBookId)
                .map { $0.map { BookDetailItem.from(recordInfo: $0) } }
                .map { Action.fetchRecordsSuccessed($0) }
                .catch { _ in Empty() }
                .eraseToAnyPublisher()
            
        case .fetchSeedStats:
            return fetchSeedStatsUseCase.execute()
                .map { Action.fetchSeedStatsSuccessed($0) }
                .catch { _ in Empty() }
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

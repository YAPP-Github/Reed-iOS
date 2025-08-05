// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

enum SearchItem: Hashable {
    case keyword(String)
    case result(Book)
}

enum SearchViewType: String {
    case globalSearch = "Global"
    case archiveSearch = "Library"
    
    var recentPlaceholder: String {
        return "최근 검색어가 없습니다."
    }

    var resultPlaceholder: String {
        switch self {
        case .globalSearch:
            return "검색어와 일치하는 도서가 없습니다."
        case .archiveSearch:
            return "내 서재에 해당 도서가 없습니다."
        }
    }
}
final class SearchViewModel: BaseViewModel {
    enum SearchState: Equatable {
        case recent([String])
        case result([Book])
    }
    
    struct State: Equatable {
        var searchState: SearchState = .recent([])
        var bookId: String?
        var noteReadied = false
        var isLoading = false
        var hasMoreData = true
        var totalResults = 0
    }
    
    enum Action {
        case onAppear
        case search(String)
        case loadNextPage
        case loadNoteFlow
        case deleteRecentQuery(String)
        case upsertBook(isbn: String, status: BookRegistrationStatus)
        case fetchRecentQueriesSuccessed([String])
        case fetchSearchResultSuccessed((books: [Book], totalResults: Int))
        case fetchNextPageSuccessed([Book])
        case upsertBookSuccessed(String)
    }
    
    enum SideEffect {
        case recentQueries
        case deleteRecentQuery(String)
        case searchResult(String)
        case loadNextPage
        case upsert(isbn: String, status: BookRegistrationStatus)
    }
    
    @Published private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    private let pageSize = 10
    private var allBooks: [Book] = []
    private var currentQuery: String?
    private var currentPage = 1
    
    @Autowired var fetchRecentSearchUseCase: FetchRecentSearchUseCase
    @Autowired var storeRecentSearchUseCase: StoreRecentSearchUseCase
    @Autowired var deleteRecentSearchUseCase: DeleteRecentSearchUseCase
    @Autowired var searchBookUseCase: SearchBookUseCase
    @Autowired var upsertUseCase: BookUpsertUseCase
    
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init(searchViewType: SearchViewType) {
        self.searchViewType = searchViewType
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
            effects.append(.recentQueries)
            
        case .search(let query):
            currentQuery = query
            currentPage = 1
            allBooks = []
            newState.isLoading = true
            effects.append(.searchResult(query))
            
        case .fetchRecentQueriesSuccessed(let queries):
            newState.searchState = .recent(queries)
            
        case .fetchSearchResultSuccessed(let result):
            allBooks = result.books
            newState.totalResults = result.totalResults
            newState.isLoading = false
            newState.searchState = .result(result.books)
            newState.hasMoreData = allBooks.count < result.totalResults
            
        case .loadNextPage:
            guard !state.isLoading, state.hasMoreData else { break }
            newState.isLoading = true
            currentPage += 1
            effects.append(.loadNextPage)
            
        case .loadNoteFlow:
            if let bookId = state.bookId {
                newState.noteReadied = true
            }
            
        case .fetchNextPageSuccessed(let books):
            let unique = books.filter { book in
                !allBooks.contains { $0.isbn == book.isbn }
            }
            
            allBooks += unique
            newState.isLoading = false
            newState.searchState = .result(allBooks)
            newState.hasMoreData = allBooks.count < newState.totalResults
            
        case .deleteRecentQuery(let query):
            effects.append(.deleteRecentQuery(query))
            
        case .upsertBook(let isbn, let status):
            effects.append(.upsert(isbn: isbn, status: status))
            
        case .upsertBookSuccessed(let bookId):
            newState.bookId = bookId
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .recentQueries:
            return fetchRecentSearchUseCase.execute()
                .map(Action.fetchRecentQueriesSuccessed)
                .eraseToAnyPublisher()
            
        case .deleteRecentQuery(let query):
            return deleteRecentSearchUseCase.execute(query: query)
                .flatMap { _ in
                    self.fetchRecentSearchUseCase.execute()
                }
                .map { Action.fetchRecentQueriesSuccessed($0) }
                .eraseToAnyPublisher()
            
        case .searchResult(let query):
            return Publishers.Zip(
                searchBookUseCase.execute(
                    query: query,
                    startIndex: currentPage
                ),
                storeRecentSearchUseCase.execute(query: query)
            )
            .map { (result, _) in
                Action.fetchSearchResultSuccessed(result)
            }
            .eraseToAnyPublisher()
            
        case .loadNextPage:
            guard let query = currentQuery else {
                return Empty().eraseToAnyPublisher()
            }
            return searchBookUseCase.execute(
                query: query,
                startIndex: currentPage
            )
            .map { Action.fetchNextPageSuccessed($0.books) }
            .eraseToAnyPublisher()
            
        case .upsert(let isbn, let status):
            return upsertUseCase.execute(
                isbn: isbn,
                status: status.toBookStatus()
            )
            .map { Action.upsertBookSuccessed($0.bookId) }
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

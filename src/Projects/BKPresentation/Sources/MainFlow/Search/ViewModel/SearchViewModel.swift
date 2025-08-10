// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

enum SearchItem: Hashable {
    case query(String)
    case result(Book)
}

struct RecentState: Equatable {
    let queries: [String]
    let placeholder: String
}

struct ResultState: Equatable {
    let books: [Book]
    let placeholder: String
}

enum SearchViewType: String {
    case defaultSearch = "Default"
    case myLibrarySearch = "MyLibrary"
    
    var recentPlaceholder: String {
        return "최근 검색어 내역이 없습니다."
    }

    var resultPlaceholder: String {
        switch self {
        case .defaultSearch:
            return "검색어와 일치하는 도서가 없습니다."
        case .myLibrarySearch:
            return "내 서재에 해당 도서가 없습니다."
        }
    }
    
    var searchBarPlaceholder: String {
        switch self {
        case .defaultSearch:
            return "도서 검색 후 내 서재에 담아보세요."
        case .myLibrarySearch:
            return "등록한 책을 검색해보세요"
        }
    }
}

struct MyLibrarySearchAdapter: SearchBookUseCase {
    let wrapped: MyLibrarySearchBookUseCase
    let map: (BookInfo) -> Book

    func execute(
        query: String?,
        startIndex: Int?
    ) -> AnyPublisher<(books: [Book], totalResults: Int), DomainError> {
        wrapped.execute(query: query, startIndex: startIndex)
            .map { (books: $0.books.map(map), totalResults: $0.totalResults) }
            .eraseToAnyPublisher()
    }
}

final class SearchViewModel: BaseViewModel {
    enum SearchState: Equatable {
        case recent(RecentState)
        case result(ResultState)
    }
    
    struct State: Equatable {
        var searchState: SearchState = .recent(
            RecentState(queries: [], placeholder: "")
        )
        var bookId: String?
        var noteReadied = false
        var isLoading = false
        var hasMoreData = true
        var totalResults = 0
        var error: DomainError? = nil
        var isRetrying: Bool = false
        var searchBarPlaceholder: String
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
        case errorOccured(DomainError)
        case errorHandled
        case retryTapped
    }
    
    enum SideEffect {
        case recentQueries
        case deleteRecentQuery(String)
        case searchResult(String)
        case loadNextPage
        case upsert(isbn: String, status: BookRegistrationStatus)
    }
    
    @Published private var state: State
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    private let pageSize = 10
    private var allBooks: [Book] = []
    private var currentQuery: String?
    private var currentPage = 1
    private let searchViewType: SearchViewType
    private var lastEffect: SideEffect? = nil
    
    private lazy var fetchRecentSearchUseCase: FetchRecentSearchUseCase = {
        @Autowired(name: searchViewType.rawValue) var useCase: FetchRecentSearchUseCase
        return useCase
    }()
    
    private lazy var storeRecentSearchUseCase: StoreRecentSearchUseCase = {
        @Autowired(name: searchViewType.rawValue) var useCase: StoreRecentSearchUseCase
        return useCase
    }()
    
    private lazy var deleteRecentSearchUseCase: DeleteRecentSearchUseCase = {
        @Autowired(name: searchViewType.rawValue) var useCase: DeleteRecentSearchUseCase
        return useCase
    }()
    
    @Autowired var defaultSearchUseCase: SearchBookUseCase
    @Autowired var myLibrarySearchUseCase: MyLibrarySearchBookUseCase
    
    private lazy var searchBookUseCase: SearchBookUseCase = {
        switch searchViewType {
        case .defaultSearch:
            return defaultSearchUseCase
        case .myLibrarySearch:
            return MyLibrarySearchAdapter(
                wrapped: myLibrarySearchUseCase,
                map: mapBookInfoToBook
            )
        }
    }()
    
    @Autowired private var upsertUseCase: BookUpsertUseCase
    
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init(searchViewType: SearchViewType) {
        self.searchViewType = searchViewType
        self.state = State(searchBarPlaceholder: searchViewType.searchBarPlaceholder)
        bindSideEffects()
    }
    
    func send(_ action: Action) {
        let (newState, effects) = reduce(action: action, state: state)
        state = newState
        debugPulse(allBooks.count)
        effects.forEach {
            lastEffect = $0
            sideEffectSubject.send($0)
        }
    }
    
    func reduce(action: Action, state: State) -> (State, [SideEffect]) {
        var newState = state
        var effects: [SideEffect] = []
        
        switch action {
        case .onAppear:
            newState.isLoading = true
            effects.append(.recentQueries)
            
        case .search(let query):
            currentQuery = query
            currentPage = searchViewType == .defaultSearch ? 1 : 0
            allBooks = []
            newState.isLoading = true
            effects.append(.searchResult(query))
            
        case .fetchRecentQueriesSuccessed(let queries):
            newState.isLoading = false
            newState.searchState = .recent(
                RecentState(
                    queries: queries,
                    placeholder: searchViewType.recentPlaceholder
                )
            )
            
        case .fetchSearchResultSuccessed(let result):
            allBooks = result.books
            newState.totalResults = result.totalResults
            newState.isLoading = false
            newState.searchState = .result(
                ResultState(
                    books: result.books,
                    placeholder: searchViewType.resultPlaceholder
                )
            )
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
            newState.searchState = .result(
                ResultState(
                    books: allBooks,
                    placeholder: searchViewType.resultPlaceholder
                )
            )
            newState.hasMoreData = allBooks.count < newState.totalResults
            
        case .deleteRecentQuery(let query):
            effects.append(.deleteRecentQuery(query))
            
        case .upsertBook(let isbn, let status):
            newState.isLoading = true
            effects.append(.upsert(isbn: isbn, status: status))
            
        case .upsertBookSuccessed(let bookId):
            newState.isLoading = false
            newState.bookId = bookId
            
        case .errorOccured(let error):
            newState.isLoading = false
            if newState.isRetrying == false {
                newState.isRetrying = true
            } else {
                newState.isRetrying = false
                newState.error = error
            }

        case .retryTapped:
            if let last = lastEffect {
                newState.isLoading = true
                effects.append(last)
            }
            
        case .errorHandled:
            newState.error = nil
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
                    .setFailureType(to: DomainError.self)
            )
            .map { (result, _) in
                Action.fetchSearchResultSuccessed(result)
            }
            .catch { [weak self] in
                self?.lastEffect = .searchResult(query)
                return Just(Action.errorOccured($0))
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
            .catch { [weak self] in
                self?.lastEffect = .loadNextPage
                return Just(Action.errorOccured($0))
            }
            .eraseToAnyPublisher()
            
        case .upsert(let isbn, let status):
            return upsertUseCase.execute(
                isbn: isbn,
                status: status.toBookStatus()
            )
            .map { Action.upsertBookSuccessed($0.bookId) }
            .catch { [weak self] in
                self?.lastEffect = .upsert(isbn: isbn, status: status)
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
    
    private func mapBookInfoToBook(_ info: BookInfo) -> Book {
        Book(
            isbn: info.isbn,
            title: info.title,
            author: info.author,
            publisher: info.publisher,
            thumbnail: info.imageUrl,
            userBookStatus: info.status,
            recordCount: info.recordCount
        )
    }
}

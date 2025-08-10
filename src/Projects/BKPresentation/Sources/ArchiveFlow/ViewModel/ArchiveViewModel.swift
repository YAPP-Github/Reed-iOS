// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import UIKit

enum ArchiveItem: Hashable {
    case chip(ChipData)
    case book(ArchiveBook)
}

final class ArchiveViewModel: BaseViewModel {
    enum ArchiveState: Equatable {
        case empty([ChipData])
        case books([ChipData], [ArchiveBook])
    }
    
    struct State: Equatable {
        var archiveState: ArchiveState = .empty(createInitialChips())
        var isLoading = false
        var selectedChipIndex = 0
        var totalBooks = 0
        var error: DomainError?
        
        static func createInitialChips() -> [ChipData] {
            ChipType.allCases.enumerated().map { index, type in
                ChipData(title: type.title, count: 0, isSelected: index == 0)
            }
        }
    }
    
    enum Action {
        case onAppear
        case chipTapped(index: Int)
        case loadNextPage

        case fetchBooksSuccessed(books: [ArchiveBook], totalCount: Int, counts: BookCountSet)
        case errorOccured(DomainError)
        case errorHandled
    }
    
    enum SideEffect {
        case fetchBooks(page: Int, status: BKDomain.BookStatus?)
        case fetchNextPage(page: Int, status: BKDomain.BookStatus?)
    }
    
    @Published private var state = State()
    @Autowired private var fetchMyLibraryUseCase: FetchMyLibraryUseCase
    
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    private var allBooks: [ArchiveBook] = []
    private var currentPage = 0
    private let pageSize = 10
    private var inflightPage: Int? = nil
    
    var statePublisher: AnyPublisher<State, Never> { $state.eraseToAnyPublisher() }
    
    init() { bindSideEffects() }
    
    func send(_ action: Action) {
        let (newState, effects) = reduce(action: action, state: state)
        state = newState
        effects.forEach { sideEffectSubject.send($0) }
    }
    
    func reduce(action: Action, state: State) -> (State, [SideEffect]) {
        var newState = state
        var effects: [SideEffect] = []
        let status = statusForChip(index: state.selectedChipIndex)
        
        switch action {
        case .onAppear:
            newState.isLoading = true
            currentPage = 0
            allBooks = []
            effects.append(.fetchBooks(page: 0, status: status))
            
        case .chipTapped(let index):
            guard index != state.selectedChipIndex else { break }
            newState.selectedChipIndex = index
            newState.isLoading = true
            currentPage = 0
            allBooks = []
            newState.totalBooks = 0
            
            // 칩 선택 즉시 반영 + 리스트 비우기
            let currentChips = getCurrentChips(from: state.archiveState)
            let updated = currentChips.enumerated().map { (i, chip) -> ChipData in
                var c = chip
                c.isSelected = (i == index)
                return c
            }
            newState.archiveState = .books(updated, [])
            
            // 선택된 칩 기준 status로 0페이지 호출
            let nextStatus = statusForChip(index: index)
            effects.append(.fetchBooks(page: 0, status: nextStatus))
            
        case .loadNextPage:
            guard !state.isLoading,
                  inflightPage == nil,
                  allBooks.count < state.totalBooks else { break }
            newState.isLoading = true
            inflightPage = currentPage
            effects.append(.fetchNextPage(page: currentPage, status: status)) // ✅ off-by-one 방지
            
        case .fetchBooksSuccessed(let books, let totalCount, let counts):
            newState.isLoading = false
            inflightPage = nil
            newState.totalBooks = totalCount
            
            if currentPage == 0 {
                allBooks = books
            } else {
                let unique = books.filter { b in !allBooks.contains(where: { $0.isbn == b.isbn }) }
                allBooks += unique
            }
            currentPage += 1
            
            let chips = buildChips(from: counts, selectedIndex: newState.selectedChipIndex)
            newState.archiveState = allBooks.isEmpty ? .empty(chips) : .books(chips, allBooks)
            
        case .errorOccured(let error):
            newState.isLoading = false
            inflightPage = nil
            newState.error = error
            
        case .errorHandled:
            newState.error = nil
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case let .fetchBooks(page, status),
             let .fetchNextPage(page, status):
            return fetchMyLibraryUseCase
                .execute(query: nil, startIndex: page, status: status)
                .map { result -> Action in
                    let mapped = result.books.map(self.mapToArchiveBook(_:))
                    return .fetchBooksSuccessed(
                        books: mapped,
                        totalCount: result.bookCountSet.totalCount,
                        counts: result.bookCountSet
                    )
                }
                .catch { Just(.errorOccured($0)) }
                .eraseToAnyPublisher()
        }
    }
    
    private func bindSideEffects() {
        sideEffectSubject
            .map { [weak self] effect in
                self?.handle(effect) ?? Empty().eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink(receiveValue: send(_:))
            .store(in: &cancellables)
    }
    
    private func getCurrentChips(from archiveState: ArchiveState) -> [ChipData] {
        switch archiveState {
        case .empty(let chips): return chips
        case .books(let chips, _): return chips
        }
    }
    
    private func buildChips(from counts: BookCountSet, selectedIndex: Int) -> [ChipData] {
        let numbers: [Int] = [
            counts.totalCount,
            counts.beforeReadingCount,
            counts.readingCount,
            counts.completedCount
        ]
        return ChipType.allCases.enumerated().map { i, type in
            ChipData(
                title: type.title,
                count: numbers[safe: i] ?? 0,
                isSelected: i == selectedIndex
            )
        }
    }
    
    private func statusForChip(index: Int) -> BKDomain.BookStatus? {
        ChipType.allCases[safe: index]?.domainBookStatus
    }
    
    private func mapToArchiveBook(_ book: BookInfo) -> ArchiveBook {
        ArchiveBook(
            isbn: book.isbn,
            bookId: book.bookId,
            title: book.title,
            author: book.author,
            publisher: book.publisher,
            status: book.status,
            imageURL: book.imageUrl,
            recordCount: book.recordCount
        )
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

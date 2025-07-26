// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import UIKit

enum ArchiveItem: Hashable {
    case chip(ChipData)
    case book(ArchiveBook)
}

enum ChipType: Int, CaseIterable {
    case total = 0
    case toRead = 1
    case reading = 2
    case completed = 3
    
    var title: String {
        switch self {
        case .total: return "전체"
        case .toRead: return "읽기 전"
        case .reading: return "읽는 중"
        case .completed: return "완독"
        }
    }
    
    var bookStatus: BookStatus? {
        switch self {
        case .total: return .total
        case .toRead: return .toRead
        case .reading: return .reading
        case .completed: return .completed
        }
    }
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
        
        static func createInitialChips() -> [ChipData] {
            return ChipType.allCases.enumerated().map { index, type in
                ChipData(
                    title: type.title,
                    count: 0,
                    isSelected: index == 0
                )
            }
        }
    }
    
    enum Action {
        case onAppear
        case chipTapped(index: Int)
        case loadNextPage
        case fetchBooksSuccessed(([ArchiveBook], totalCount: Int))
        case fetchChipsSuccessed([ChipData])
    }
    
    enum SideEffect {
        case fetchBooks(status: BookStatus?)
        case loadNextPage(status: BookStatus?)
        case fetchChips
    }
    
    @Published private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    private var allBooks: [ArchiveBook] = []
    private var currentPage = 1
    private var currentStatus: BookStatus? = .total
    
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init() {
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
            newState.isLoading = true
            effects.append(.fetchChips)
            effects.append(.fetchBooks(status: currentStatus))
            
        case .chipTapped(let index):
            if index == state.selectedChipIndex {
                break
            }
            
            newState.selectedChipIndex = index
            newState.isLoading = true
            currentPage = 1
            allBooks = []
            
            let status = bookStatusForChipIndex(index)
            currentStatus = status
            effects.append(.fetchBooks(status: status))
            
            let currentChips = getCurrentChips(from: state.archiveState)
            let updatedChips = currentChips.enumerated().map { (i, chip) -> ChipData in
                var newChip = chip
                newChip.isSelected = (i == index)
                return newChip
            }
            
            if case .empty = newState.archiveState {
                newState.archiveState = .empty(updatedChips)
            } else if case .books(_, let books) = newState.archiveState {
                newState.archiveState = .books(updatedChips, books)
            }
            
        case .loadNextPage:
            guard !state.isLoading else { break }
            newState.isLoading = true
            currentPage += 1
            effects.append(.loadNextPage(status: currentStatus))
            
        case .fetchChipsSuccessed(let chips):
            let updatedChips = ChipType.allCases.enumerated().map { index, type in
                let count = chips[index].count
                return ChipData(
                    title: type.title,
                    count: count,
                    isSelected: index == newState.selectedChipIndex
                )
            }

            if case .empty = state.archiveState {
                newState.archiveState = .empty(updatedChips)
            } else if case .books(_, let books) = state.archiveState {
                newState.archiveState = .books(updatedChips, books)
            }
            
        case .fetchBooksSuccessed(let (books, totalCount)):
            allBooks = books
            newState.totalBooks = totalCount
            newState.isLoading = false
            
            let currentChips = getCurrentChips(from: state.archiveState)
            let updatedChipsBasedOnSelection = currentChips.enumerated().map { (i, chip) -> ChipData in
                var newChip = chip
                newChip.isSelected = (i == newState.selectedChipIndex)
                return newChip
            }
            
            if books.isEmpty {
                newState.archiveState = .empty(updatedChipsBasedOnSelection)
            } else {
                newState.archiveState = .books(updatedChipsBasedOnSelection, books)
            }
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .fetchChips:
            return Just(createMockChips())
                .map(Action.fetchChipsSuccessed)
                .eraseToAnyPublisher()
            
        case .fetchBooks(let status):
            return Just(createMockBooks(for: status))
                .map { books in
                    Action.fetchBooksSuccessed((books, totalCount: books.count))
                }
                .eraseToAnyPublisher()
            
        case .loadNextPage(let status):
            return Just(createMockBooks(for: status))
                .map { books in
                    let uniqueBooks = books.filter { book in
                        !self.allBooks.contains { $0 == book }
                    }
                    let updatedBooks = self.allBooks + uniqueBooks
                    return Action.fetchBooksSuccessed((updatedBooks, totalCount: updatedBooks.count))
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
    
    // MARK: - Helper Methods
    
    private func bookStatusForChipIndex(_ index: Int) -> BookStatus? {
        switch index {
        case 0: return .total
        case 1: return .toRead // 읽기 전
        case 2: return .reading // 읽는 중
        case 3: return .completed // 완독
        default:
            return nil
        }
    }
    
    private func getCurrentChips(from archiveState: ArchiveState) -> [ChipData] {
        switch archiveState {
        case .empty(let chips):
            return chips
        case .books(let chips, _):
            return chips
        }
    }
    
    // MARK: - Mock Data (실제 구현에서는 제거)
    
    private func createMockChips() -> [ChipData] {
        return [
            ChipData(title: "전체", count: 2, isSelected: true),
            ChipData(title: "읽기 전", count: 0, isSelected: false),
            ChipData(title: "읽는 중", count: 0, isSelected: false),
            ChipData(title: "완독", count: 0, isSelected: false)
        ]
    }
    
    private func createMockBooks(for status: BookStatus?) -> [ArchiveBook] {
        // 임시 Mock 데이터
        if status == .total { // 전체
            return [
                ArchiveBook(
                    isbn: "1234",
                    title: "여름은 오래 그곳에 남아",
                    author: "미쓰이에 다카시",
                    publisher: "비채",
                    imageURL: URL(string: "https://example.com/book1.jpg"),
                    recordCount: 24
                ),
                ArchiveBook(
                    isbn: "5678",
                    title: "쇼펜하우어 인생수업 한 번 뿐인 삶 이...",
                    author: "쇼펜하우어",
                    publisher: "민음사",
                    imageURL: URL(string: "https://example.com/book2.jpg"),
                    recordCount: 24
                )
            ]
        } else {
            return [] // 다른 상태는 빈 배열 반환 (테스트용)
        }
    }
}

enum BookStatus: String, CaseIterable {
    case total = "전체"
    case toRead = "읽기 전"
    case reading = "읽는 중"
    case completed = "완독"
}

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
        guard index < ChipType.allCases.count else { return nil }
        return ChipType.allCases[index].bookStatus
    }
    
    private func getCurrentChips(from archiveState: ArchiveState) -> [ChipData] {
        switch archiveState {
        case .empty(let chips):
            return chips
        case .books(let chips, _):
            return chips
        }
    }
    
    // MARK: - Mock Data -> API 연결 후 삭제
    
    private func createMockChips() -> [ChipData] {
        return [
            ChipData(title: "전체", count: 4),
            ChipData(title: "읽기 전", count: 2),
            ChipData(title: "읽는 중", count: 2),
            ChipData(title: "완독", count: 0)
        ]
    }
    
    private func createMockBooks(for status: BookStatus?) -> [ArchiveBook] {
        // 임시 Mock 데이터 -> API 연결 후 삭제
        switch status {
        case .total: // 전체 (4개)
            return [
                ArchiveBook(
                    isbn: "1234",
                    title: "여름은 오래 그곳에 남아",
                    author: "미쓰이에 다카시",
                    publisher: "비채",
                    imageURL: URL(string: "https://image.aladin.co.kr/product/7492/9/cover500/8934972203_1.jpg"),
                    recordCount: 24
                ),
                ArchiveBook(
                    isbn: "5678",
                    title: "쇼펜하우어 인생수업",
                    author: "쇼펜하우어",
                    publisher: "민음사",
                    imageURL: URL(string: "https://image.aladin.co.kr/product/33464/3/cover500/k082938849_3.jpg"),
                    recordCount: 15
                ),
                ArchiveBook(
                    isbn: "9101",
                    title: "작별인사",
                    author: "김영하",
                    publisher: "복복서가",
                    imageURL: URL(string: "https://image.aladin.co.kr/product/29281/68/cover500/k122837904_2.jpg"),
                    recordCount: 0
                ),
                ArchiveBook(
                    isbn: "1121",
                    title: "불편한 편의점",
                    author: "김호연",
                    publisher: "나무옆의자",
                    imageURL: URL(string: "https://image.aladin.co.kr/product/29045/74/cover500/k192836746_2.jpg"),
                    recordCount: 0
                )
            ]
            
        case .toRead: // 읽기 전 (2개)
            return [
                ArchiveBook(
                    isbn: "9101",
                    title: "작별인사",
                    author: "김영하",
                    publisher: "복복서가",
                    imageURL: URL(string: "https://image.aladin.co.kr/product/29281/68/cover500/k122837904_2.jpg"),
                    recordCount: 0
                ),
                ArchiveBook(
                    isbn: "1121",
                    title: "불편한 편의점",
                    author: "김호연",
                    publisher: "나무옆의자",
                    imageURL: URL(string: "https://image.aladin.co.kr/product/29045/74/cover500/k192836746_2.jpg"),
                    recordCount: 0
                )
            ]
            
        case .reading: // 읽는 중 (2개)
            return [
                ArchiveBook(
                    isbn: "1234",
                    title: "여름은 오래 그곳에 남아",
                    author: "미쓰이에 다카시",
                    publisher: "비채",
                    imageURL: URL(string: "https://image.aladin.co.kr/product/7492/9/cover500/8934972203_1.jpg"),
                    recordCount: 24
                ),
                ArchiveBook(
                    isbn: "5678",
                    title: "쇼펜하우어 인생수업",
                    author: "쇼펜하우어",
                    publisher: "민음사",
                    imageURL: URL(string: "https://image.aladin.co.kr/product/33464/3/cover500/k082938849_3.jpg"),
                    recordCount: 15
                )
            ]
            
        case .completed: // 완독 (0개)
            return []
            
        default:
            return []
        }
    }
}

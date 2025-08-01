// Copyright © 2025 Booket. All rights reserved

import Combine
import BKDomain
import Foundation

final class BookDetailViewModel: BaseViewModel {
    struct State {
        var items: [BookDetailItem] = []
        var currentBook: Book? = nil
        var sortOption: SortOption = .pageDescending
    }
    
    enum Action {
        case onAppear
        case changeSortOption(SortOption)
    }
    
    enum SideEffect {
    }
    
    @Published private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
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
            newState.items = Constants.mockResult
            newState.currentBook = Constants.mockBook
        case .changeSortOption(let option):
            newState.sortOption = option
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
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

private extension BookDetailViewModel {
    enum Constants {
        static let mockBook = Book(
            isbn: "11",
            title: "오브젝트",
            author: "조영호",
            publisher: "위키북스",
            thumbnail: nil,
            userBookStatus: "READING"
        )
        
        static let mockResult = [
            BookDetailItem(
                note: """
                “책을 읽으면 차분해지며 숲으로 둘러싸인 여름 별장 속으로 간 것 같은 기분이 든다.
                그 곳에서 그들이 품은 건축에 대한 이상과 삶을 구경하는 것만으로도 충분했다.
                책을 읽으면 차분해지며 숲으로 둘러싸인 여름 별장 속으로 간 것 같은 기분이 든다.
                그 곳에서 그들이 품은 건축에 대한 이상과 삶을 구경하는 것만으로도 충분했다.“
                """,
                emotion: .joy,
                createdAt: Date(),
                page: 100
            ),
            BookDetailItem(
                note: """
                “책을 읽으면 차분해지며 숲으로 둘러싸인 여름 별장 속으로 간 것 같은 기분이 든다.
                그 곳에서 그들이 품은 건축에 대한 이상과 삶을 구경하는 것만으로도 충분했다.
                책을 읽으면 차분해지며 숲으로 둘러싸인 여름 별장 속으로 간 것 같은 기분이 든다.
                그 곳에서 그들이 품은 건축에 대한 이상과 삶을 구경하는 것만으로도 충분했다.“
                """,
                emotion: .joy,
                createdAt: Date(),
                page: 100
            ),
            BookDetailItem(
                note: """
                “책을 읽으면 차분해지며 숲으로 둘러싸인 여름 별장 속으로 간 것 같은 기분이 든다.
                그 곳에서 그들이 품은 건축에 대한 이상과 삶을 구경하는 것만으로도 충분했다.
                책을 읽으면 차분해지며 숲으로 둘러싸인 여름 별장 속으로 간 것 같은 기분이 든다.
                그 곳에서 그들이 품은 건축에 대한 이상과 삶을 구경하는 것만으로도 충분했다.“
                """,
                emotion: .tension,
                createdAt: Date(),
                page: 100
            ),
            BookDetailItem(
                note: """
                “책을 읽으면 차분해지며 숲으로 둘러싸인 여름 별장 속으로 간 것 같은 기분이 든다.
                그 곳에서 그들이 품은 건축에 대한 이상과 삶을 구경하는 것만으로도 충분했다.
                책을 읽으면 차분해지며 숲으로 둘러싸인 여름 별장 속으로 간 것 같은 기분이 든다.
                그 곳에서 그들이 품은 건축에 대한 이상과 삶을 구경하는 것만으로도 충분했다.“
                """,
                emotion: .sadness,
                createdAt: Date(),
                page: 100
            ),
            BookDetailItem(
                note: """
                “책을 읽으면 차분해지며 숲으로 둘러싸인 여름 별장 속으로 간 것 같은 기분이 든다.
                그 곳에서 그들이 품은 건축에 대한 이상과 삶을 구경하는 것만으로도 충분했다.
                책을 읽으면 차분해지며 숲으로 둘러싸인 여름 별장 속으로 간 것 같은 기분이 든다.
                그 곳에서 그들이 품은 건축에 대한 이상과 삶을 구경하는 것만으로도 충분했다.“
                """,
                emotion: .warmth,
                createdAt: Date(),
                page: 100
            )
        ]
    }
}

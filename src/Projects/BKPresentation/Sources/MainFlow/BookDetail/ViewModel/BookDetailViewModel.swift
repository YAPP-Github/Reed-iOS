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
                “1장: 객체, 설계
                01. 티켓 판매 애플리케이션 구현하기
                02. 무엇이 문제인가“
                """,
                emotion: .joy,
                createdAt: Date(),
                page: 12
            ),
            BookDetailItem(
                note: """
                “03. 설계 개선하기
                ___자율성을 높이자
                ___무엇이 개선됐는가
                ___어떻게 한 것인가“
                """,
                emotion: .joy,
                createdAt: Date(),
                page: 64
            ),
            BookDetailItem(
                note: """
                “04. 객체지향 설계
                ___설계가 왜 필요한가
                ___객체지향 설계“
                """,
                emotion: .tension,
                createdAt: Date(),
                page: 96
            ),
            BookDetailItem(
                note: """
                “___ 협력, 객체, 클래스“
                """,
                emotion: .sadness,
                createdAt: Date(),
                page: 125
            )
        ]
    }
}

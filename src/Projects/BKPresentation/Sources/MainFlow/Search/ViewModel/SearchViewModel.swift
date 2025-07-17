// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import UIKit.UIImage

enum SearchItem: Hashable {
    case keyword(String)
    case result(SearchResult)
}

struct SearchResult: Hashable {
    let thumbnail: UIImage
    let title: String
    let description: String
}

final class SearchViewModel: BaseViewModel {
    struct State: Equatable {
        var searchState: SearchState = .recent([])
        
        enum SearchState: Equatable {
            case recent([String])
            case result([SearchResult])
        }
    }
    
    enum Action {
        case onAppear
        case fetchRecentQueriesSuccessed([String])
    }
    
    enum SideEffect {
        case recentQueries
    }
    
    @Published private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    @Autowired var fetchRecentSearchUseCase: FetchRecentSearchUseCase
    
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
            effects.append(.recentQueries)
        case .fetchRecentQueriesSuccessed(let queries):
            newState.searchState = .recent(queries)
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .recentQueries:
            fetchRecentSearchUseCase.execute()
                .map(Action.fetchRecentQueriesSuccessed)
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


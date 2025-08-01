// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine

final class HomeViewModel: BaseViewModel {
    struct State: Equatable {
        var homeInfos: [HomeBookInfo] = []
    }
    
    enum Action {
        case onAppear
        case fetchHomeSuccessed([HomeBookInfo])
    }
    
    enum SideEffect {
        case fetch
    }
    
    @Published private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    @Autowired var fetchHomeUseCase: FetchHomeUseCase
    
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
            effects.append(.fetch)
        case .fetchHomeSuccessed(let homeInfos):
            newState.homeInfos = homeInfos
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .fetch:
            fetchHomeUseCase.execute()
                .catch { _ in Empty() }
                .map { $0.map { HomeBookInfo.from($0) }}
                .map { Action.fetchHomeSuccessed($0) }
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

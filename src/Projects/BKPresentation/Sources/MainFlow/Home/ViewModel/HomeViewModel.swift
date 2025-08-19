// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine

final class HomeViewModel: BaseViewModel {
    struct State: Equatable {
        var homeInfos: [HomeBookInfo] = []
        var isLoading: Bool = false
        var shouldPlayAnimation: Bool = false
        var error: DomainError? = nil
    }
    
    enum Action {
        case onAppear
        case onDisappear
        case fetchHomeSuccessed([HomeBookInfo])
        case errorOccured(DomainError)
        case errorHandled
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
        
        AccessModeCenter.shared.mode
            .sink { [weak self] mode in
                if mode == .member {
                    self?.send(.onAppear)
                }
            }
            .store(in: &cancellables)
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
            guard AccessModeCenter.shared.mode.value == .member else {
                newState.shouldPlayAnimation = true
                newState.homeInfos = []
                break
            }
            newState.isLoading = true
            effects.append(.fetch)
            newState.shouldPlayAnimation = true
        case .onDisappear:
            newState.shouldPlayAnimation = false

        case .fetchHomeSuccessed(let homeInfos):
            newState.isLoading = false
            newState.homeInfos = homeInfos
            
        case .errorOccured(let error):
            newState.isLoading = false
            newState.error = error
            
        case .errorHandled:
            newState.error = nil
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .fetch:
            fetchHomeUseCase.execute()
                .map { $0.map { HomeBookInfo.from($0) }}
                .map { Action.fetchHomeSuccessed($0) }
                .catch { Just(Action.errorOccured($0)) }
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

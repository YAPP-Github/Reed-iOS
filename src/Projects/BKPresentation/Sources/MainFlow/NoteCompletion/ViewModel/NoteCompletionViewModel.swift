// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine

final class NoteCompletionViewModel: BaseViewModel {
    struct State {
        var recordInfo: RecordInfo?
        var isLoading: Bool = false
        var error: DomainError?
    }
    
    enum Action {
        case onAppear
        case fetchRecordDetailSuccessed(RecordInfo)
        case errorOccured(DomainError)
        case errorHandled
    }
    
    enum SideEffect {
        case fetchRecordDetail(String)
    }
    
    @Published private var state: State
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    @Autowired private var fetchRecordDetailUseCase: FetchRecordDetailUseCase
    
    private let recordId: String
    
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init(recordId: String) {
        self.recordId = recordId
        self.state = State()
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
            effects.append(.fetchRecordDetail(recordId))
            
        case .fetchRecordDetailSuccessed(let recordInfo):
            newState.recordInfo = recordInfo
            newState.isLoading = false
            
        case .errorOccured(let error):
            newState.error = error
            newState.isLoading = false
            
        case .errorHandled:
            newState.error = nil
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .fetchRecordDetail(let id):
            return fetchRecordDetailUseCase.execute(id: id)
                .map { Action.fetchRecordDetailSuccessed($0) }
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

// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine

final class NoteCompletionViewModel: BaseViewModel {
    struct State {
        var recordInfo: RecordInfo?
        var isLoading: Bool = false
        var error: DomainError?
        var deleteCompleted: Bool = false
        var shareTriggered: Bool = false
    }
    
    enum Action {
        case onAppear
        case fetchRecordDetailSuccessed(RecordInfo)
        case errorOccured(DomainError)
        case errorHandled
        case deleteButtonTapped
        case deleteRecordSuccessed
        case shareButtonTapped
        case shareHandled
    }
    
    enum SideEffect {
        case fetchRecordDetail(String)
        case deleteRecord(String)
    }
    
    @Published private var state: State
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    @Autowired private var fetchRecordDetailUseCase: FetchRecordDetailUseCase
    @Autowired private var deleteRecordUseCase: DeleteRecordUseCase
    
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
            
        case .deleteButtonTapped:
            newState.isLoading = true
            effects.append(.deleteRecord(recordId))
            
        case .deleteRecordSuccessed:
            newState.isLoading = false
            newState.deleteCompleted = true
            
        case .shareButtonTapped:
            newState.shareTriggered = true
            
        case .shareHandled:
            newState.shareTriggered = false
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
                
        case .deleteRecord(let id):
            return deleteRecordUseCase.execute(recordId: id)
                .map { _ in Action.deleteRecordSuccessed }
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

// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

final class NoteViewModel: BaseViewModel {
    struct State: Equatable {
        var selectedGuideText: String = ""
        var createCompleted: Bool = false
        var shouldStartEditing: Bool = false
    }
    
    enum Action {
        case appreciationGuideSelected(String)
        case submitNoteForm(NoteForm)
        case submitNoteFormSuccessed
    }
    
    enum SideEffect {
        case submit(NoteForm)
    }
    
    @Published private var state: State = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    private let bookId: String
    
    @Autowired var createRecordUseCase: CreateRecordUseCase
    
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init(bookId: String) {
        self.bookId = bookId
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
        case .appreciationGuideSelected(let guideText):
            newState.selectedGuideText = guideText
            newState.shouldStartEditing = true
            
        case .submitNoteForm(let noteForm):
            effects.append(.submit(noteForm))
            
        case .submitNoteFormSuccessed:
            newState.createCompleted = true
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .submit(let noteForm):
            return createRecordUseCase.execute(
                bookId: bookId,
                record: noteForm.toRecordVO()
            )
            .map { Action.submitNoteFormSuccessed }
            .catch { _ in Empty() }
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


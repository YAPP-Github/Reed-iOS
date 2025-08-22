// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

final class NoteEditViewModel: BaseViewModel {
    struct State {
        var recordInfo: RecordInfo?
        var selectedEmotion: Emotion?
        var isLoading: Bool = false
        var error: DomainError?
        var shouldPresentEmotionEdit: (emotion: Emotion?, timestamp: Date)?
        var saveCompleted: Bool = false
        var deleteCompleted: Bool = false
    }
    
    enum Action {
        case onAppear
        case fetchRecordDetailSuccessed(RecordInfo)
        case errorOccured(DomainError)
        case errorHandled
        case presentEmotionEdit
        case emotionSelected(Emotion)
        case saveButtonTapped(formData: (page: Int?, sentence: String, appreciation: String))
        case patchRecordSuccessed(RecordInfo)
        case deleteButtonTapped
        case deleteRecordSuccessed
    }
    
    enum SideEffect {
        case fetchRecordDetail(String)
        case patchRecord(String, NoteForm)
        case deleteRecord(String)
    }
    
    @Published private var state: State
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    @Autowired private var fetchRecordDetailUseCase: FetchRecordDetailUseCase
    @Autowired private var patchRecordUseCase: PatchRecordUseCase
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
            // 사용자가 이미 감정을 선택했다면 덮어쓰지 않음
            if newState.selectedEmotion == nil {
                newState.selectedEmotion = recordInfo.emotionTags.first
            }
            newState.isLoading = false
            
        case .errorOccured(let error):
            newState.error = error
            newState.isLoading = false
            
        case .errorHandled:
            newState.error = nil
            
        case .presentEmotionEdit:
            newState.shouldPresentEmotionEdit = (emotion: state.selectedEmotion, timestamp: Date())
            
        case .emotionSelected(let emotion):
            newState.selectedEmotion = emotion
            
        case .saveButtonTapped(let formData):
            guard let selectedEmotion = state.selectedEmotion,
                  let page = formData.page,
                  !formData.sentence.isEmpty,
                  !formData.appreciation.isEmpty else { 
                break 
            }
            
            let noteForm = NoteForm(
                page: page,
                sentence: formData.sentence,
                emotion: selectedEmotion,
                appreciation: formData.appreciation
            )
            
            newState.isLoading = true
            effects.append(.patchRecord(recordId, noteForm))
            
        case .patchRecordSuccessed(let recordInfo):
            newState.recordInfo = recordInfo
            newState.isLoading = false
            newState.saveCompleted = true
            
        case .deleteButtonTapped:
            newState.isLoading = true
            effects.append(.deleteRecord(recordId))
            
        case .deleteRecordSuccessed:
            newState.isLoading = false
            newState.deleteCompleted = true
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
                
        case .patchRecord(let id, let noteForm):
            return patchRecordUseCase.execute(
                recordId: id,
                record: noteForm.toRecordVO()
            )
            .map { Action.patchRecordSuccessed($0) }
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


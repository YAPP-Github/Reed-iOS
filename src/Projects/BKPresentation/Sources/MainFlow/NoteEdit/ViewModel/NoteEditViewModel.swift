// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

final class NoteEditViewModel: BaseViewModel {
    struct State {
        var recordInfo: RecordInfo?
        var selectedPrimaryEmotion: PrimaryEmotion?
        var selectedDetailEmotions: [DetailEmotion] = []
        var isLoading: Bool = false
        var error: DomainError?
        var shouldPresentEmotionEdit: (emotion: PrimaryEmotion?, timestamp: Date)?
        var saveCompleted: Bool = false
        var deleteCompleted: Bool = false

        var currentFormData: (page: String, sentence: String, memo: String) = ("", "", "")

        var initialRecordInfo: RecordInfo?
        var initialSelectedPrimaryEmotion: PrimaryEmotion?
        var initialSelectedDetailEmotions: [DetailEmotion] = []
        var isDiff: Bool = false // 변경 내용이 있는지 추적

        // Detail emotion sheet 관련 상태
        var detailEmotions: [DetailEmotion] = []
        var isLoadingEmotions: Bool = false

        // NoteEditViewController에서 사용하는 별칭 (backward compatibility)
        var selectedEmotion: PrimaryEmotion? {
            selectedPrimaryEmotion
        }
    }

    enum Action {
        case onAppear
        case fetchRecordDetailSuccessed(RecordInfo)
        case errorOccured(DomainError)
        case errorHandled
        case presentEmotionEdit
        case emotionSelected(PrimaryEmotion)

        case saveButtonTapped
        case patchRecordSuccessed(RecordInfo)
        case deleteButtonTapped
        case deleteRecordSuccessed

        case pageDidChange(String)
        case sentenceDidChange(String)
        case memoDidChange(String)

        // Detail emotion sheet
        case fetchDetailEmotions(PrimaryEmotion)
        case detailEmotionsFetched([DetailEmotion])
        case detailEmotionsSelected([DetailEmotion])
    }

    enum SideEffect {
        case fetchRecordDetail(String)
        case patchRecord(String, NoteForm)
        case deleteRecord(String)
        case fetchDetailEmotions(PrimaryEmotion)
    }
    
    @Published private var state: State
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    @Autowired private var fetchRecordDetailUseCase: FetchRecordDetailUseCase
    @Autowired private var patchRecordUseCase: PatchRecordUseCase
    @Autowired private var deleteRecordUseCase: DeleteRecordUseCase
    @Autowired private var fetchDetailEmotionsUseCase: FetchDetailEmotionsUseCase
    
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
            guard state.initialRecordInfo == nil else {
                break
            }
            newState.isLoading = true
            newState.isDiff = false
            effects.append(.fetchRecordDetail(recordId))
            
        case .fetchRecordDetailSuccessed(let recordInfo):
            newState.recordInfo = recordInfo
            newState.initialRecordInfo = recordInfo

            newState.currentFormData = (
                page: recordInfo.pageNumber.map { "\($0)" } ?? "",
                sentence: recordInfo.quote,
                memo: recordInfo.review ?? ""
            )

            // 사용자가 이미 감정을 선택했다면 덮어쓰지 않음
            if newState.selectedPrimaryEmotion == nil {
                newState.selectedPrimaryEmotion = recordInfo.primaryEmotion
                newState.initialSelectedPrimaryEmotion = recordInfo.primaryEmotion
                newState.selectedDetailEmotions = recordInfo.detailEmotions
                newState.initialSelectedDetailEmotions = recordInfo.detailEmotions
            }
            newState.isLoading = false
            newState.isDiff = false
            
        case .errorOccured(let error):
            newState.error = error
            newState.isLoading = false
            
        case .errorHandled:
            newState.error = nil
            
        case .presentEmotionEdit:
            newState.shouldPresentEmotionEdit = (emotion: state.selectedPrimaryEmotion, timestamp: Date())

        case .emotionSelected(let emotion):
            newState.selectedPrimaryEmotion = emotion
            // 감정이 변경되면 세부감정 초기화
            newState.selectedDetailEmotions = []
            newState.isDiff = checkForDiff(state: newState)
            
        case .saveButtonTapped:
            guard let selectedPrimaryEmotion = state.selectedPrimaryEmotion,
                  !state.currentFormData.sentence.isEmpty else {
                break
            }

            // 페이지가 비어있으면 nil
            let page = Int(state.currentFormData.page)

            // 메모가 비어있으면 nil, 아니면 텍스트 전달
            let memo = state.currentFormData.memo.isEmpty
            ? nil
            : state.currentFormData.memo

            let noteForm = NoteForm(
                page: page,
                sentence: state.currentFormData.sentence,
                memo: memo,
                primaryEmotion: selectedPrimaryEmotion,
                detailEmotions: state.selectedDetailEmotions
            )

            newState.isLoading = true
            effects.append(.patchRecord(recordId, noteForm))
            
        case .patchRecordSuccessed(let recordInfo):
            newState.recordInfo = recordInfo
            newState.initialRecordInfo = recordInfo
            newState.currentFormData = (
                page: recordInfo.pageNumber.map { "\($0)" } ?? "",
                sentence: recordInfo.quote,
                memo: recordInfo.review ?? ""
            )
            newState.isLoading = false
            newState.saveCompleted = true
            newState.isDiff = false
            
        case .deleteButtonTapped:
            newState.isLoading = true
            effects.append(.deleteRecord(recordId))
            
        case .deleteRecordSuccessed:
            newState.isLoading = false
            newState.deleteCompleted = true
            
        case .pageDidChange(let text):
            newState.currentFormData.page = text
            newState.isDiff = checkForDiff(state: newState)
            
        case .sentenceDidChange(let text):
            newState.currentFormData.sentence = text
            newState.isDiff = checkForDiff(state: newState)
            
        case .memoDidChange(let text):
            newState.currentFormData.memo = text
            newState.isDiff = checkForDiff(state: newState)

        case .fetchDetailEmotions(let emotion):
            newState.isLoadingEmotions = true
            effects.append(.fetchDetailEmotions(emotion))

        case .detailEmotionsFetched(let emotions):
            newState.detailEmotions = emotions
            newState.isLoadingEmotions = false

        case .detailEmotionsSelected(let emotions):
            newState.selectedDetailEmotions = emotions
            newState.isDiff = checkForDiff(state: newState)
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

        case .fetchDetailEmotions(let emotion):
            return fetchDetailEmotionsUseCase.execute(for: emotion)
                .map { Action.detailEmotionsFetched($0) }
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
    
    private func checkForDiff(state: State) -> Bool {
        guard let initialInfo = state.initialRecordInfo else {
            return false
        }

        let pageDiff = state.currentFormData.page != (initialInfo.pageNumber.map { "\($0)" } ?? "")
        let sentenceDiff = state.currentFormData.sentence != initialInfo.quote
        let memoDiff = state.currentFormData.memo != (initialInfo.review ?? "")

        let emotionDiff = state.selectedPrimaryEmotion != state.initialSelectedPrimaryEmotion
        let detailEmotionDiff = state.selectedDetailEmotions != state.initialSelectedDetailEmotions

        return pageDiff || sentenceDiff || memoDiff || emotionDiff || detailEmotionDiff
    }
}


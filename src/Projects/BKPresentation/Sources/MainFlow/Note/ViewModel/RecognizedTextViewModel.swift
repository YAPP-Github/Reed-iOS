// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

final class RecognizedTextViewModel: BaseViewModel {
    
    // MARK: - Core Components
    struct State: Equatable {
        var sentences: [SentenceItem] = []
        var selectedSentences: Set<Int> = []
        var isConfirmButtonEnabled: Bool = false
        var errorMessage: String?
    }
    
    struct SentenceItem: Equatable, Hashable {
        let id: Int
        let text: String
        var isSelected: Bool = false
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(text)
            hasher.combine(isSelected)
        }
    }
    
    enum Action {
        case viewDidLoad([String])
        case sentenceToggled(index: Int)
        case confirmButtonTapped
        case retakeButtonTapped
    }
    
    enum SideEffect {
        case confirmWithSelectedText(String)
        case dismissToRetake
    }
    
    // MARK: - Properties
    @Published private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    var sideEffectPublisher: AnyPublisher<SideEffect, Never> {
        sideEffectSubject.eraseToAnyPublisher()
    }
    
    init() {
        bindSideEffects()
    }
    
    // MARK: - Methods
    func send(_ action: Action) {
        let (newState, effects) = reduce(action: action, state: state)
        state = newState
        effects.forEach { sideEffectSubject.send($0) }
    }
    
    func reduce(
        action: Action,
        state: State
    ) -> (State, [SideEffect]) {
        var newState = state
        var effects: [SideEffect] = []
        
        newState.errorMessage = nil
        
        switch action {
        case .viewDidLoad(let sentenceStrings):
            newState.sentences = sentenceStrings.enumerated().map { index, sentence in
                SentenceItem(id: index, text: sentence)
            }
            
        case .sentenceToggled(let index):
            guard index < newState.sentences.count else { break }
            
            newState.sentences[index].isSelected.toggle()
            
            // 선택된 문장들의 인덱스 업데이트
            newState.selectedSentences = Set(
                newState.sentences.enumerated().compactMap { idx, sentence in
                    sentence.isSelected ? idx : nil
                }
            )
            
        case .confirmButtonTapped:
            let selectedTexts = newState.sentences
                .filter { $0.isSelected }
                .map { $0.text }
            
            if !selectedTexts.isEmpty {
                let combinedText = selectedTexts.joined(separator: " ")
                effects.append(.confirmWithSelectedText(combinedText))
            }
            
        case .retakeButtonTapped:
            effects.append(.dismissToRetake)
        }
        
        // 확인 버튼 활성화 상태 업데이트
        newState.isConfirmButtonEnabled = newState.sentences.contains { $0.isSelected }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .confirmWithSelectedText, .dismissToRetake:
            // 이 경우들은 Coordinator나 상위 컴포넌트에서 처리
            return Empty().eraseToAnyPublisher()
        }
    }
    
    private func bindSideEffects() {
        sideEffectSubject
            .flatMap { [weak self] effect in
                self?.handle(effect) ?? Empty().eraseToAnyPublisher()
            }
            .sink(receiveValue: send)
            .store(in: &cancellables)
    }
}

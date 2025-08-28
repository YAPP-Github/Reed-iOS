// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation
import NaturalLanguage
import VisionKit
import UIKit

final class OCRScannerViewModel: BaseViewModel {
    struct State: Equatable {
        var isScanning: Bool = false
        var capturedText: String?
        var capturedSentences: [String] = []
        var shouldShowAlert: Bool = false
        var shouldShowDialog: Bool = false
        var failureCount: Int = 0
        var isLoading: Bool = false
    }
    
    enum Action {
        case viewDidLoad
        case startScanning
        case stopScanning
        case itemsAdded([RecognizedItem], allItems: [RecognizedItem])
        case itemsUpdated([RecognizedItem], allItems: [RecognizedItem])
        case itemsRemoved([RecognizedItem], allItems: [RecognizedItem])
        case captureButtonTapped
        case closeButtonTapped
        case textCaptured(String)
        case visionTextCaptured([String])
        case alertDismissed
        case dialogDismissed
        case resetFailureCount
    }
    
    enum SideEffect {
        case showRecognizedSentences([String])
        case dismissScanner
    }
    
    // MARK: - Properties
    @Published private var state = State()
    private var currentRecognizedItems: [RecognizedItem] = []
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    var sideEffectPublisher: AnyPublisher<SideEffect, Never> {
        sideEffectSubject.eraseToAnyPublisher()
    }
    
    private let nlp = NLPPostprocessor()

    init() { bindSideEffects() }
    
    // MARK: - Methods
    func send(_ action: Action) {
        let (newState, effects) = reduce(action: action, state: state)
        state = newState
        effects.forEach { sideEffectSubject.send($0) }
    }
    
    func reduce(action: Action, state: State) -> (State, [SideEffect]) {
        var newState = state
        var effects: [SideEffect] = []
        newState.shouldShowAlert = false
        
        switch action {
        case .viewDidLoad:
            break
            
        case .startScanning:
            newState.isScanning = true
            
        case .stopScanning:
            newState.isScanning = false
            
        case .itemsAdded(_, let allItems),
             .itemsUpdated(_, let allItems),
             .itemsRemoved(_, let allItems):
            currentRecognizedItems = allItems
            
        case .captureButtonTapped:
            newState.isLoading = true
            let rawLines = extractTexts(items: currentRecognizedItems)
            
            if !rawLines.isEmpty {
                let sentences = normalizeToSentences(rawLines)
                let scored = nlp.reflowWithScores(sentences: sentences)
                let finalSentences = nlp.spellcheckEnglishIfNeeded(scored.map(\.text))
                
                newState.failureCount = 0
                newState.capturedSentences = finalSentences
                newState.capturedText = finalSentences.joined(separator: "\n")
                newState.isLoading = false
                effects.append(.showRecognizedSentences(finalSentences))
            } else {
                newState.failureCount += 1
                newState.isLoading = false
                newState.shouldShowDialog = newState.failureCount >= 3
                newState.shouldShowAlert = !newState.shouldShowDialog
            }
            
        case .closeButtonTapped:
            effects.append(.dismissScanner)
            
        case .textCaptured(let text):
            newState.capturedText = text
            
        case .visionTextCaptured(let texts):
            newState.isLoading = true
            let sentences = normalizeToSentences(texts)
            
            let scored = nlp.reflowWithScores(sentences: sentences)
            let finalSentences = nlp.spellcheckEnglishIfNeeded(scored.map(\.text))
            
            newState.failureCount = 0
            newState.capturedSentences = finalSentences
            newState.capturedText = finalSentences.joined(separator: "\n")
            newState.isLoading = false
            effects.append(.showRecognizedSentences(finalSentences))
            
        case .alertDismissed:
            newState.shouldShowAlert = false
            
        case .dialogDismissed:
            newState.shouldShowDialog = false
            
        case .resetFailureCount:
            newState.failureCount = 0
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .showRecognizedSentences:
            return Empty().eraseToAnyPublisher()
        case .dismissScanner:
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

// MARK: - Text Processing
private extension OCRScannerViewModel {
    func extractTexts(items: [RecognizedItem]) -> [String] {
        var texts: [String] = []
        for item in items {
            if case let .text(recognizedText) = item {
                texts.append(recognizedText.transcript)
            }
        }
        return texts
    }
    
    func normalizeToSentences(_ lines: [String]) -> [String] {
        var text = lines.joined(separator: "\n")
        
        text = text.replacingOccurrences(of: "-\\s*\\n", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\s+([.,?!…])", with: "$1", options: .regularExpression)
        text = text.replacingOccurrences(of: "[\"\"]", with: "\"", options: .regularExpression)
        text = text.replacingOccurrences(of: "['']", with: "'",  options: .regularExpression)
        text = text.replacingOccurrences(of: "[\\u00A0\\u2001-\\u200B\\u202F\\u2060\\u3000\\uFEFF]", with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\u00AD", with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
        
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        var sentences: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let sentence = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty { sentences.append(sentence) }
            return true
        }
        return sentences
    }
}

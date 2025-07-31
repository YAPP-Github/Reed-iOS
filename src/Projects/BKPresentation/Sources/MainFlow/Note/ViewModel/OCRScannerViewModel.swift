// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation
import VisionKit

final class OCRScannerViewModel: BaseViewModel {
    
    // MARK: - Core Components
    struct State: Equatable {
        var isScanning: Bool = false
        var errorMessage: String?
        var capturedText: String?
        var capturedSentences: [String] = []
        var shouldShowAlert: Bool = false
        var alertMessage: String = ""
    }
    
    enum Action {
        case viewDidLoad
        case startScanning
        case stopScanning
        case itemsAdded([RecognizedItem], allItems: [RecognizedItem])
        case itemsUpdated([RecognizedItem], allItems: [RecognizedItem])
        case itemsRemoved([RecognizedItem], allItems: [RecognizedItem])
        case captureButtonTapped(scanAreaFrame: CGRect)
        case closeButtonTapped
        case textCaptured(String)
        case alertDismissed
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
        
        // 기본적으로 에러나 알림 상태 초기화
        newState.errorMessage = nil
        newState.shouldShowAlert = false
        
        switch action {
        case .viewDidLoad:
            break
            
        case .startScanning:
            newState.isScanning = true
            
        case .stopScanning:
            newState.isScanning = false
            
        case .itemsAdded(_, let allItems):
            currentRecognizedItems = allItems
            
        case .itemsUpdated(_, let allItems):
            currentRecognizedItems = allItems
            
        case .itemsRemoved(_, let allItems):
            currentRecognizedItems = allItems
            
        case .captureButtonTapped(let scanAreaFrame):
            let capturedTexts = extractTextsInScanArea(
                items: currentRecognizedItems,
                scanAreaFrame: scanAreaFrame
            )
            if !capturedTexts.isEmpty {
                // 각 캡처된 텍스트를 문장별로 파싱
                var allSentences: [String] = []
                
                for capturedText in capturedTexts {
                    let parsedSentences = parseSentencesToStrings(from: capturedText)
                    allSentences.append(contentsOf: parsedSentences)
                }
                
                newState.capturedSentences = allSentences
                
                // 기존 방식도 유지 (호환성을 위해)
                let combinedText = capturedTexts.joined(separator: "\n")
                newState.capturedText = combinedText
                
                // 문장 배열로 전달
                effects.append(.showRecognizedSentences(allSentences))
            } else {
                newState.shouldShowAlert = true
                newState.alertMessage = "스캔 영역에서 텍스트를 찾을 수 없습니다.\n텍스트가 초록색 테두리 안에 있는지 확인해주세요."
            }
            
        case .closeButtonTapped:
            effects.append(.dismissScanner)
            
        case .textCaptured(let text):
            newState.capturedText = text
            
        case .alertDismissed:
            newState.shouldShowAlert = false
            newState.alertMessage = ""
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .showRecognizedSentences(let textList):
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
    
    // MARK: - Private Methods
    private func extractTextsInScanArea(
        items: [RecognizedItem],
        scanAreaFrame: CGRect
    ) -> [String] {
        var capturedTexts: [String] = []
        
        for item in items {
            switch item {
            case .text(let textItem):
                let textFrame = convertToViewCoordinates(textItem.bounds)
                let textCenter = CGPoint(x: textFrame.midX, y: textFrame.midY)
                
                if scanAreaFrame.contains(textCenter) {
                    capturedTexts.append(textItem.transcript)
                }
            default:
                break
            }
        }
        
        return capturedTexts
    }
    
    private func convertToViewCoordinates(_ bounds: RecognizedItem.Bounds) -> CGRect {
        let minX = min(bounds.topLeft.x, bounds.bottomLeft.x)
        let maxX = max(bounds.topRight.x, bounds.bottomRight.x)
        let minY = min(bounds.topLeft.y, bounds.topRight.y)
        let maxY = max(bounds.bottomLeft.y, bounds.bottomRight.y)
        
        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }
    
    private func parseSentencesToStrings(from text: String) -> [String] {
        var sentences: [String] = []
        var currentSentence = ""
        
        for char in text {
            currentSentence.append(char)
            
            // 문장 부호를 만나면 문장 완성
            if char == "." || char == "!" || char == "?" {
                let trimmedSentence = currentSentence.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedSentence.isEmpty {
                    sentences.append(trimmedSentence)
                }
                currentSentence = ""
            }
        }
        
        // 마지막에 문장 부호가 없는 경우 처리
        if !currentSentence.isEmpty {
            let trimmedSentence = currentSentence.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedSentence.isEmpty {
                sentences.append(trimmedSentence)
            }
        }
        
        return sentences
    }
}

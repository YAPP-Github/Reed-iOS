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
        var capturedText: String?
        var capturedSentences: [String] = []
        
        // 에러 핸들링
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
        case captureButtonTapped(scanAreaFrame: CGRect)
        case closeButtonTapped
        case textCaptured(String)
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
            debugPulse("\(newState.failureCount)")
            newState.isLoading = true
            let capturedTexts = extractTextsInScanArea(
                items: currentRecognizedItems,
                scanAreaFrame: scanAreaFrame
            )
            
            if !capturedTexts.isEmpty {
                newState.failureCount = 0
                
                newState.capturedSentences = capturedTexts
                let combinedText = capturedTexts.joined(separator: "\n")
                
                newState.capturedText = combinedText
                newState.isLoading = false
                effects.append(.showRecognizedSentences(capturedTexts))
            } else {
                newState.failureCount += 1
                newState.isLoading = false
                
                if newState.failureCount >= 3 {
                    newState.shouldShowDialog = true
                } else {
                    newState.shouldShowAlert = true
                }
            }
            
        case .closeButtonTapped:
            effects.append(.dismissScanner)
            
        case .textCaptured(let text):
            newState.capturedText = text
            
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
                    let lines = textItem.transcript.components(separatedBy: .newlines)
                    
                    for line in lines {
                        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        debugPulse("\(trimmedLine)")
                        
                        if !trimmedLine.isEmpty {
                            capturedTexts.append(trimmedLine)
                        }
                    }
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
}

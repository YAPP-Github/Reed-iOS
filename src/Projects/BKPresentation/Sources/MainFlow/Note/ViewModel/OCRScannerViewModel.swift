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
        case showRecognizedText(String)
        case dismissScanner
    }
    
    // MARK: - Properties
    @Published private var state = State()
    private var currentRecognizedItems: [RecognizedItem] = [] // 별도 관리
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
                let combinedText = capturedTexts.joined(separator: "\n")
                newState.capturedText = combinedText
                effects.append(.showRecognizedText(combinedText))
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
        case .showRecognizedText(let text):
            // 이 경우는 Coordinator에서 처리하므로 빈 Publisher 반환
            return Empty().eraseToAnyPublisher()
            
        case .dismissScanner:
            // 이 경우도 Coordinator에서 처리하므로 빈 Publisher 반환
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
}

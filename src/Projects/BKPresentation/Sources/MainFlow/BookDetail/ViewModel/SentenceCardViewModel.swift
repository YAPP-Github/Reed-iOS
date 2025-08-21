// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation
import Photos
import UIKit

final class SentenceCardViewModel: BaseViewModel {
    struct State {
        var data: BookDetailItem?
        var alertInfo: String?
        var isLoading: Bool = false
    }
    
    enum Action {
        case onAppear
        case didTapSaveButton(image: UIImage)
        case saveImageResult(Result<Void, Error>)
        case alertDismissed
        case prepareToSaveImage
    }
    
    enum SideEffect {
        case saveImage(UIImage)
    }

    @Published private var state: State
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init(_ data: BookDetailItem) {
        self.state = State(data: data)
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
            break
        case .didTapSaveButton(let image):
            effects.append(.saveImage(image))
        case .saveImageResult(let result):
            newState.isLoading = false
            switch result {
            case .success:
                newState.alertInfo = "이미지를 저장했습니다!"
            case .failure(let error):
                // TODO : error는 로그로 찍어서 수집하기
                newState.alertInfo = "[저장 실패] 잠시 후 다시 시도해주세요."
            }
        case .alertDismissed:
            newState.alertInfo = nil
        case .prepareToSaveImage:
            newState.isLoading = true
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .saveImage(let image):
            return Future<Result<Void, Error>, Never> { promise in
                PHPhotoLibrary.requestAuthorization { status in
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }, completionHandler: { success, error in
                    if success {
                        promise(.success(.success(())))
                    } else if let error = error {
                        promise(.success(.failure(error)))
                    }
                })
            }
            .map { Action.saveImageResult($0) }
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

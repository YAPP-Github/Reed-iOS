// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import BKDomain
import Combine
import UIKit

final class EmotionEditViewController: BaseViewController<EmotionEditView> {
    override var bkNavigationTitle: String { "" }
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .standard(viewController: self)
    }
    
    weak var coordinator: NoteEditCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    private let initialEmotion: Emotion?
    @Published private var selectedEmotion: Emotion?
    private let completion: (Emotion) -> Void
    
    init(currentEmotion: Emotion?, completion: @escaping (Emotion) -> Void) {
        self.initialEmotion = currentEmotion
        self.completion = completion
        self._selectedEmotion = .init(initialValue: currentEmotion)
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let emotion = initialEmotion {
            contentView.setSelectedEmotion(emotion)
        }
        contentView.setEditButtonEnabled(false)
    }
    
    override func bindAction() {
        contentView.eventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .emotionDidChange(let newEmotion):
                    self.selectedEmotion = newEmotion
                    let isDiff = (newEmotion != self.initialEmotion)
                    self.contentView.setEditButtonEnabled(isDiff)
                case .editButtonTapped:
                    if let emotion = self.selectedEmotion {
                        self.completion(emotion)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            .store(in: &cancellables)
    }
}

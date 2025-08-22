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
    
    private let currentEmotion: Emotion?
    private let completion: (Emotion) -> Void
    
    init(currentEmotion: Emotion?, completion: @escaping (Emotion) -> Void) {
        self.currentEmotion = currentEmotion
        self.completion = completion
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 현재 선택된 감정이 있으면 초기 설정
        if let emotion = currentEmotion {
            contentView.setSelectedEmotion(emotion)
        }
    }
    
    override func bindAction() {
        contentView.editButtonTappedPublisher
            .compactMap { [weak self] in self?.contentView.selectedEmotion }
            .sink { [weak self] selectedEmotion in
                self?.completion(selectedEmotion)
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
}

// Copyright © 2025 Booket. All rights reserved

import UIKit
import BKDomain
import Combine

final class NoteEditCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    private let recordId: String
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController,
        recordId: String
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.recordId = recordId
    }
    
    func start() {
        let viewController = NoteEditViewController(
            viewModel: NoteEditViewModel(recordId: recordId)
        )
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }
}

extension NoteEditCoordinator: AuthenticationRequiredNotifying, ErrorHandleable {
    func notifyAuthenticationRequired(onFinish: (() -> Void)?) {
        (parentCoordinator as? AuthenticationRequiredNotifying)?.notifyAuthenticationRequired(onFinish: onFinish)
    }
}

extension NoteEditCoordinator {
    func didTapEmotionEdit(currentEmotion: Emotion?, completion: @escaping (Emotion) -> Void) {
        let emotionEditViewController = EmotionEditViewController(
            currentEmotion: currentEmotion,
            completion: completion
        )
        emotionEditViewController.coordinator = self
        navigationController.pushViewController(emotionEditViewController, animated: true)
    }
}

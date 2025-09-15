// Copyright © 2025 Booket. All rights reserved

import BKCore
import Combine
import UIKit

enum OnboardingViewEvent {
    case onboardingDidFinish
}

final class OnboardingViewController: BaseViewController<OnboardingView>, ScreenLoggable {
    var screenName: String = GATracking.OnboardingAndAuth.onboarding

    weak var coordinator: OnboardingCoordinator?
    private var cancellable = Set<AnyCancellable>()
    
    override var bkNavigationTitle: String { "" }
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .standard(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logScreenView()
    }
    
    override func bindAction() {
        contentView.eventPublisher
            .filter { $0 == .onboardingDidFinish }
            .sink { [weak self] _ in
                self?.coordinator?.popAndFinish()
            }
            .store(in: &cancellable)
    }
}

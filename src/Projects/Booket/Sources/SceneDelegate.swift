// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import BKDesign
import BKDomain
import BKNetwork
import BKPresentation
import BKStorage
import KakaoSDKAuth
import Pulse
import PulseUI
import SwiftUI
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: Coordinator?
    let navigationController = UINavigationController()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        setupNavigationBar()
        window = PulseWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        assembleDependencies()
        startScene()
    }
    
    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        if let url = URLContexts.first?.url {
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
}

private extension SceneDelegate {
    func startScene() {
        @Autowired var authStateUseCase: AuthStateUseCase
        @Autowired var onboardingCheckUseCase: OnboardingCheckUseCase
        self.coordinator = AppCoordinator(
            navigationController: navigationController,
            authStateUseCase: authStateUseCase,
            onboardingCheckUseCase: onboardingCheckUseCase
        )
        coordinator?.start()
    }
    
    func assembleDependencies() {
        DIContainer.shared.assemble([StorageAssembly(), NetworkAssembly(), DataAssembly(), DomainAssembly()])
    }
    
    func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .bkBaseColor(.primary)
        appearance.shadowColor = .clear
        
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationItem.largeTitleDisplayMode = .never
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
    }
}

class PulseWindow: UIWindow {
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        guard motion == .motionShake else { return }
        
        let viewController = MainViewController()
        let navigation = UINavigationController(rootViewController: viewController)
        rootViewController?.present(navigation, animated: true)
    }
}

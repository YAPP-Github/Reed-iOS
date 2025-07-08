// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import BKDomain
import BKNetwork
import BKPresentation
import BKStorage
import UIKit
import KakaoSDKAuth

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
        window = UIWindow(windowScene: windowScene)
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
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
}

private extension SceneDelegate {
    func startScene() {
        @Autowired var authStateUseCase: AuthStateUseCase
        self.coordinator = AppCoordinator(
            navigationController: navigationController,
            authStateUseCase: authStateUseCase
        )
        coordinator?.start()
    }
    
    func assembleDependencies() {
        DIContainer.shared.assemble([StorageAssembly(), NetworkAssembly(), DataAssembly(), DomainAssembly()])
    }
}

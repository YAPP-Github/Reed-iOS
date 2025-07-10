// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let viewController = BKButtonTestViewController()
//        let viewController = BKButtonGroupDemoViewController()
        window.rootViewController = UINavigationController(rootViewController: viewController)
        window.makeKeyAndVisible()

        self.window = window
    }
}

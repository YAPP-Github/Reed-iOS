// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let navigationController = UINavigationController()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        setupNavigationBar()
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        navigationController.pushViewController(CatalogViewController(), animated: true)
    }
    
    func setupNavigationBar() {
        guard let font = BKTextStyle.headline2(weight: .semiBold).uiFont else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.bkContentColor(.primary),
            .font: font
        ]
        appearance.backgroundColor = .bkBaseColor(.primary)
        appearance.shadowColor = .clear
        
        let barButtonAppearance = UIBarButtonItemAppearance()
        barButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]
        
        let backButtonImage = BKImage.Icon.chevronLeft
            .withRenderingMode(.alwaysTemplate)
            .withAlignmentRectInsets(
                UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
            )
        
        appearance.backButtonAppearance = barButtonAppearance
        appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        
        navigationController.navigationBar.tintColor = .bkContentColor(.primary)
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.isTranslucent = false
    }
}

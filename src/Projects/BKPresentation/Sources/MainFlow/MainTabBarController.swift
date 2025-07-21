// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit

enum TabItem: CaseIterable {
    case home
    case archive

    var viewController: UIViewController {
        switch self {
        case .home:
            return HomeViewController()
        case .archive:
            return HomeViewController()
        }
    }

    var title: String {
        switch self {
        case .home: return "홈"
        case .archive: return "내 서재"
        }
    }

    var icon: UIImage? {
        switch self {
        case .home: return BKImage.Icon.home
        case .archive: return BKImage.Icon.archive
        }
    }
}

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        customizeTabBarAppearance()
    }

    private func setupViewControllers() {
        let viewControllerList = TabItem.allCases.map { item -> UINavigationController in
            let viewController = item.viewController
            viewController.tabBarItem = UITabBarItem(
                title: item.title,
                image: item.icon?.withTintColor(.bkBackgroundColor(.disable)),
                selectedImage: item.icon?.withTintColor(.bkContentColor(.primary))
            )
            return UINavigationController(rootViewController: viewController)
        }
        self.viewControllers = viewControllerList
    }

    private func customizeTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .bkBaseColor(.primary)
        
        appearance.shadowColor = UIColor(hex: "6D6D6D").withAlphaComponent(0.05)
        
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.bkContentColor(.primary)]
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.bkContentColor(.secondary)]

        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        appearance.stackedLayoutAppearance.normal.iconColor = .bkBackgroundColor(.disable)
        appearance.stackedLayoutAppearance.selected.iconColor = .bkContentColor(.primary)

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height: CGFloat = 92

        var tabFrame = tabBar.frame
        tabFrame.size.height = height
        tabFrame.origin.y = view.frame.height - height
        tabBar.frame = tabFrame

        tabBar.layer.cornerRadius = BKRadius.large
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.layer.masksToBounds = true

        // 그림자 값 조정 더 해야함
        tabBar.layer.shadowColor = UIColor(hex: "6D6D6D").cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        tabBar.layer.shadowRadius = 10
    }
}

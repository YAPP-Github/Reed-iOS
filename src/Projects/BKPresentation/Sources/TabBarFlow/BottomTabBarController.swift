// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit

final class BottomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeTabBarAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    private func customizeTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .bkBaseColor(.primary)
        
        appearance.shadowColor = UIColor(hex: "6D6D6D").withAlphaComponent(0.05)
        
        let normalAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.bkContentColor(.secondary)]
        let selectedAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.bkContentColor(.primary)]

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

        // TODO: - 그림자 값 조정 더 해야함
        tabBar.layer.shadowColor = UIColor(hex: "6D6D6D").cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        tabBar.layer.shadowRadius = 10
    }
}

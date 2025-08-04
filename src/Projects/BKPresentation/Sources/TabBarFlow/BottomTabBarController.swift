// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit

final class BottomTabBarController: UITabBarController {
    private var shadowView: UIView?
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupTabBarFrame()
        let customLayer = createCustomTabBarLayer()
        applyCustomLayer(customLayer)
    }
    
}

// MARK: - TabBar Appearance
private extension BottomTabBarController {
    func customizeTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .bkBaseColor(.primary)
        appearance.shadowColor = .clear
        
        setupTabBarTextAttributes(appearance: appearance)
        setupTabBarIconColors(appearance: appearance)
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    func setupTabBarTextAttributes(appearance: UITabBarAppearance) {
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.bkContentColor(.secondary),
            .font: BKTextStyle.caption2(weight: .regular).uiFont
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.bkContentColor(.primary),
            .font: BKTextStyle.caption2(weight: .regular).uiFont
        ]

        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
    }
    
    func setupTabBarIconColors(appearance: UITabBarAppearance) {
        appearance.stackedLayoutAppearance.normal.iconColor = .bkBackgroundColor(.disable)
        appearance.stackedLayoutAppearance.selected.iconColor = .bkContentColor(.primary)
    }
    
    func setupTabBarFrame() {
        let baseHeight: CGFloat = 58
        let bottomInset = view.safeAreaInsets.bottom
        let height = baseHeight + bottomInset

        var tabFrame = tabBar.frame
        tabFrame.size.height = height
        tabFrame.origin.y = view.frame.height - height
        tabBar.frame = tabFrame

        tabBar.layer.sublayers?.removeAll { $0.name == "customTabBarLayer" }
    }
    
    func createCustomTabBarLayer() -> CAShapeLayer {
        let customLayer = CAShapeLayer()
        customLayer.name = "customTabBarLayer"
        
        let tabFrame = tabBar.frame
        let cornerRadius = BKRadius.large
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addLine(to: CGPoint(x: tabFrame.width - cornerRadius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: tabFrame.width, y: cornerRadius),
            controlPoint: CGPoint(x: tabFrame.width, y: 0)
        )
        path.addLine(to: CGPoint(x: tabFrame.width, y: tabFrame.height))
        path.addLine(to: CGPoint(x: 0, y: tabFrame.height))
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: 0),
            controlPoint: CGPoint(x: 0, y: 0)
        )
        path.close()
        
        customLayer.path = path.cgPath
        customLayer.fillColor = UIColor.bkBaseColor(.primary).cgColor
        customLayer.strokeColor = UIColor.bkBorderColor(.primary).cgColor
        customLayer.lineWidth = 1.0
        
        customLayer.shadowColor = UIColor(hex: "6D6D6D").cgColor
        customLayer.shadowOpacity = 0.1
        customLayer.shadowOffset = CGSize(width: 0, height: -4)
        customLayer.shadowRadius = 10
        customLayer.masksToBounds = false
        
        return customLayer
    }
    
    func applyCustomLayer(_ customLayer: CAShapeLayer) {
        tabBar.backgroundColor = .clear
        tabBar.layer.insertSublayer(customLayer, at: 0)
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit

extension UINavigationController {
    /// standard의 경우 Title이 중앙에 있고 백버튼을 쓰는 스타일입니다.
    /// main의 경우, 주로 TabBar에 연결될 View들이 사용해야 합니다. 타이틀이 Leading에 있는 스타일입니다.
    enum BKNavigationBarStyle {
        /// 주로 more 버튼을 설정하기 위한 `rightButton` 파라미터입니다.
        case standard(
            viewController: UIViewController,
            rightButton: StandardRightButton? = nil
        )
        
        /// 검색 버튼과 기어(설정) 버튼에 대해 `addTarget(_:)`을 하기 위한 파라미터들입니다.
        case main(
            viewController: UIViewController,
            target: Any?,
            searchAction: Selector,
            gearAction: Selector
        )
        
        /// 홈 화면 전용 스타일
        case home(
            viewController: UIViewController,
            target: Any?,
            gearAction: Selector
        )
    }
    
    struct StandardRightButton {
        let image: UIImage
        let isEnabled: Bool
        weak var target: AnyObject?
        let action: Selector?
        
        init(
            image: UIImage = BKImage.Icon.moreVertical,
            isEnabled: Bool = true,
            target: AnyObject? = nil,
            action: Selector? = nil
        ) {
            self.image = image
            self.isEnabled = isEnabled
            self.target = target
            self.action = action
        }
    }
    
    func applyStyleIfNeeded(for viewController: UIViewController) {
        guard let stylable = viewController as? BKNavigationBarStylable else { return }
        applyNavigationBarStyle(title: stylable.bkNavigationTitle, style: stylable.bkNavigationBarStyle)
    }
    
    private func applyNavigationBarStyle(
        title: String,
        style: BKNavigationBarStyle
    ) {
        switch style {
        case .standard(
            let viewController,
            let rightButton
        ):
            makeStandardStyle(
                title: title,
                for: viewController,
                rightButton: rightButton
            )
            
        case .main(
            let viewController,
            let target,
            let searchAction,
            let gearAction
        ):
            makeMainStyle(
                title: title,
                for: viewController,
                target: target,
                searchAction: searchAction,
                gearAction: gearAction
            )
            
        case .home(
            let viewController,
            let target,
            let gearAction
        ):
            makeHomeStyle(
                title: title,
                for: viewController,
                target: target,
                gearAction: gearAction
            )
        }
    }
}

private extension UINavigationController {
    func makeStandardStyle(
        title: String,
        for viewController: UIViewController,
        rightButton: StandardRightButton?
    ) {
        let appearance = makeStandardAppearance()
        configureBackButton(in: appearance)
        applyStandardRightButton(rightButton, to: viewController)
        
        viewController.navigationItem.title = title
        
        navigationBar.tintColor = .bkContentColor(.primary)
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.isTranslucent = false
    }
    
    func makeMainStyle(
        title: String,
        for viewController: UIViewController,
        target: Any?,
        searchAction: Selector,
        gearAction: Selector
    ) {
        let searchButton = makeIconButton(BKImage.Icon.search, target: target, action: searchAction)
        let gearButton = makeIconButton(BKImage.Icon.settings, target: target, action: gearAction)
        searchButton.tintColor = .bkContentColor(.primary)
        gearButton.tintColor = .bkContentColor(.primary)
        
        navigationBar.tintColor = .bkContentColor(.primary)
        viewController.navigationItem.title = nil
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: makeLeadingTitle(title))
        viewController.navigationItem.rightBarButtonItem = makeRightButtons([searchButton, gearButton])
    }
    
    func makeHomeStyle(
        title: String,
        for viewController: UIViewController,
        target: Any?,
        gearAction: Selector
    ) {
        let gearButton = makeIconButton(BKImage.Icon.settings, target: target, action: gearAction)
        gearButton.tintColor = .bkContentColor(.primary)
        
        navigationBar.tintColor = .bkContentColor(.primary)
        viewController.navigationItem.title = nil
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: makeHomeTitleView(title))
        viewController.navigationItem.rightBarButtonItem = makeRightButtons([gearButton])
    }
    
    func makeHomeTitleView(_ text: String) -> UIView {
        let label = BKLabel()
        let font = BKTextStyle.title1(weight: .bold).uiFont!
        let attr = NSMutableAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: UIColor.bkContentColor(.brand)
        ])
        label.attributedText = attr
        label.sizeToFit()
        
        let wrapper = UIView()
        wrapper.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(BKInset.inset1)
            $0.centerY.equalToSuperview()
        }
        return wrapper
    }
    
    func makeLeadingTitle(_ text: String) -> UIView {
        let label = BKLabel()
        let font = BKTextStyle.heading1(weight: .bold).uiFont!
        let attr = NSMutableAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: UIColor.bkContentColor(.primary)
        ])
        label.attributedText = attr
        label.sizeToFit()
        
        let wrapper = UIView()
        wrapper.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(BKInset.inset1)
            $0.centerY.equalToSuperview()
        }
        return wrapper
    }
    
    func makeRightButtons(_ buttons: [UIButton]) -> UIBarButtonItem {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.spacing = BKSpacing.spacing5
        stack.alignment = .center
        
        let wrapper = UIView()
        wrapper.addSubview(stack)
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 0, left: 0, bottom: 0, right: BKInset.inset1)
            )
        }
        return UIBarButtonItem(customView: wrapper)
    }
    
    func makeIconButton(_ image: UIImage, target: Any?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }
    
    func makeStandardAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        if let font = BKTextStyle.headline2(weight: .semiBold).uiFont {
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.bkContentColor(.primary),
                .font: font
            ]
        }
        
        appearance.backgroundColor = .bkBaseColor(.primary)
        appearance.shadowColor = .clear
        return appearance
    }
    
    func configureBackButton(in appearance: UINavigationBarAppearance) {
        let barButtonAppearance = UIBarButtonItemAppearance()
        barButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonAppearance
        
        let backImage = BKImage.Icon.chevronLeft
            .withRenderingMode(.alwaysTemplate)
            .withAlignmentRectInsets(
                UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
            )
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
    }
    
    func applyStandardRightButton(
        _ buttonInfo: StandardRightButton?,
        to viewController: UIViewController
    ) {
        guard
            let info = buttonInfo,
            let action = info.action
        else {
            viewController.navigationItem.rightBarButtonItem = nil
            return
        }
        
        let button = makeIconButton(
            info.image,
            target: info.target,
            action: action
        )
        button.isEnabled = info.isEnabled
        
        viewController.navigationItem.rightBarButtonItem =
        makeRightButtons([button])
    }
}

// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public class BKButtonGroup: UIView {
    
    // MARK: - Types
    public enum Layout {
        case horizontal
        case vertical
        case fullWidth
    }
    
    // MARK: - Properties
    private let stackView = UIStackView()
    private var buttons: [BKButton] = []
    
    public var layout: Layout = .horizontal {
        didSet {
            updateLayout()
        }
    }
    
    public var spacing: CGFloat = BKSpacing.spacing2 {
        didSet {
            stackView.spacing = spacing
        }
    }
    
    // MARK: - Initialization
    
    public init(
        buttons: [BKButton],
        layout: Layout = .horizontal,
        spacing: CGFloat = BKSpacing.spacing2
    ) {
        self.buttons = buttons
        self.layout = layout
        self.spacing = spacing
        super.init(frame: .zero)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        updateLayout()
        updateButtons()
    }
    
    // MARK: - Public Methods
    public func setButtons(_ buttons: [BKButton]) {
        self.buttons = buttons
        updateButtons()
    }
    
    public func addButton(_ button: BKButton) {
        buttons.append(button)
        updateButtons()
    }
    
    public func removeButton(_ button: BKButton) {
        if let index = buttons.firstIndex(of: button) {
            buttons.remove(at: index)
            updateButtons()
        }
    }
    
    public func removeAllButtons() {
        buttons.removeAll()
        updateButtons()
    }
    
    // MARK: - Private Methods
    private func updateLayout() {
        switch layout {
        case .horizontal:
            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally
            stackView.alignment = .fill
            buttons.forEach { $0.isFullWidth = false }
            
        case .vertical:
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.alignment = .fill
            buttons.forEach { $0.isFullWidth = true }
            
        case .fullWidth:
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.alignment = .fill
            buttons.forEach { $0.isFullWidth = true }
        }
        
        stackView.spacing = spacing
    }
    
    private func updateButtons() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        buttons.forEach { button in
            button.setContentHuggingPriority(.required, for: .horizontal)
            stackView.addArrangedSubview(button)
        }

        updateLayout()
    }

}

// MARK: - Convenience Initializers
extension BKButtonGroup {
    public static func twoButtonGroup(
        leftTitle: String = "확인",
        rightTitle: String = "취소",
        leftAction: (() -> Void)? = nil,
        rightAction: (() -> Void)? = nil
    ) -> BKButtonGroup {
        let leftButton = BKButton.secondary(title: leftTitle)
        let rightButton = BKButton.primary(title: rightTitle)
        
        if let action = leftAction {
            leftButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
        }
        
        if let action = rightAction {
            rightButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
        }
        
        return BKButtonGroup(buttons: [leftButton, rightButton], layout: .fullWidth)
    }
    
    public static func singleFullButton(
        title: String = "다음",
        action: (() -> Void)? = nil
    ) -> BKButtonGroup {
        let nextButton = BKButton.primary(title: title, size: .large)
        
        if let action = action {
            nextButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
        }
        
        return BKButtonGroup(buttons: [nextButton], layout: .vertical)
    }
    
    /// 3개 버튼 수평 그룹
    public static func threeButtonGroup(
        leftTitle: String,
        centerTitle: String,
        rightTitle: String,
        leftAction: (() -> Void)? = nil,
        centerAction: (() -> Void)? = nil,
        rightAction: (() -> Void)? = nil
    ) -> BKButtonGroup {
        let leftButton = BKButton.tertiary(title: leftTitle)
        let centerButton = BKButton.secondary(title: centerTitle)
        let rightButton = BKButton.primary(title: rightTitle)
        
        if let action = leftAction {
            leftButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
        }
        
        if let action = centerAction {
            centerButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
        }
        
        if let action = rightAction {
            rightButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
        }
        
        return BKButtonGroup(buttons: [leftButton, centerButton, rightButton], layout: .horizontal)
    }
    
    /// 수직 버튼 그룹
    public static func verticalButtonGroup(
        buttons: [BKButton],
        spacing: CGFloat = BKSpacing.spacing2
    ) -> BKButtonGroup {
        buttons.forEach { $0.isFullWidth = true }
        return BKButtonGroup(buttons: buttons, layout: .vertical, spacing: spacing)
    }
}

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
    public var primaryButton: BKButton? {
        didSet {
            guard let primaryButton else { return }
            if !buttons.contains(primaryButton) {
                self.primaryButton = oldValue
            }
        }
    }
    
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
        stackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(BKSpacing.spacing5)
            $0.verticalEdges.equalToSuperview().inset(BKSpacing.spacing4)
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
    
    public func setPrimaryButtonState(_ state: Bool) {
        primaryButton?.isEnabled = state
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
            stackView.distribution = .fillEqually
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
    
    /// 두 개 버튼으로 구성된 그룹의 액션을 나중에 설정하거나 교체합니다.
    /// - Warning: 이 함수는 내부에 버튼이 2개 있을 때만 정상 동작합니다. 기존에 설정된 모든 액션은 제거됩니다.
    public func bindTwoButtonsAction(leftAction: (() -> Void)?, rightAction: (() -> Void)?) {
        guard buttons.count == 2 else {
            print("Warning: bindTwoButtonsAction() called on a button group that does not have 2 buttons.")
            return
        }
        
        let leftButton = buttons[0]
        let rightButton = buttons[1]
        
        leftButton.removeTarget(nil, action: nil, for: .allEvents)
        rightButton.removeTarget(nil, action: nil, for: .allEvents)
        
        if let action = leftAction {
            leftButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
        }
        
        if let action = rightAction {
            rightButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
        }
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
        
        let group = BKButtonGroup(buttons: [leftButton, rightButton], layout: .fullWidth)
        group.primaryButton = rightButton
        return group
    }
    
    public static func singleFullButton(
        title: String = "다음",
        action: (() -> Void)? = nil
    ) -> BKButtonGroup {
        let nextButton = BKButton.primary(title: title, size: .large)
        
        if let action = action {
            nextButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
        }
        
        let group = BKButtonGroup(buttons: [nextButton], layout: .vertical)
        group.primaryButton = nextButton
        return group
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
    ///
    /// - Warning: 입력된 버튼들의 isFullWidth 속성이 true로 변경됩니다.
    public static func verticalButtonGroup(
        buttons: [BKButton],
        spacing: CGFloat = BKSpacing.spacing2
    ) -> BKButtonGroup {
        buttons.forEach { $0.isFullWidth = true }
        return BKButtonGroup(buttons: buttons, layout: .vertical, spacing: spacing)
    }
}

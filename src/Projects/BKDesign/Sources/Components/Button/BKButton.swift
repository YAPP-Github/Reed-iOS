// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public class BKButton: UIButton, BKButtonProtocol {
    
    @SetNeeds(.layout, .display)
    public var style: BKButtonStyle = .primary {
        didSet {
            updateButtonStyle()
        }
    }
    
    @SetNeeds(.layout)
    public var size: BKButtonSize = .medium {
        didSet {
            updateButtonSize()
        }
    }
    
    @SetNeeds(wrappedValue: nil, .layout)
    public var title: String? {
        didSet {
            setTitle("", for: .normal) // UIButton 기본 타이틀 제거
            customTitleLabel.text = title
            updateLayout()
        }
    }
    
    @SetNeeds(wrappedValue: nil, .layout)
    public var leftIcon: UIImage? {
        didSet {
            updateLeftIcon()
            updateLayout()
        }
    }
    
    @SetNeeds(wrappedValue: nil, .layout)
    public var rightIcon: UIImage? {
        didSet {
            updateRightIcon()
            updateLayout()
        }
    }
    
    @SetNeeds(.layout, .display)
    public var isDisabled: Bool = false {
        didSet {
            isEnabled = !isDisabled
            updateButtonState()
        }
    }
    
    public var isFullWidth: Bool = false {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Override UIButton Properties
    public override var isHighlighted: Bool {
        didSet {
            updateButtonState()
            animatePressedState()
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            updateButtonState()
        }
    }
    
    // MARK: - Private Properties
    // 커스텀 레이아웃을 위한 뷰
    private let customContainerView = UIView()
    private let leftIconView = UIImageView()
    private let customTitleLabel = UILabel()
    private let rightIconView = UIImageView()
    private let stackView = UIStackView()
    
    // Animation properties
    private let pressedScale: CGFloat = 0.96
    private let animationDuration: TimeInterval = 0.15
    private let animationSpringDamping: CGFloat = 0.7
    private let animationSpringVelocity: CGFloat = 0.5
    
    private var currentState: BKButtonState {
        return BKButtonState(isEnabled: isEnabled, isHighlighted: isHighlighted)
    }
    
    // MARK: - Initialization
    public init(style: BKButtonStyle = .primary, size: BKButtonSize = .medium) {
        super.init(frame: .zero)
        self.style = style
        self.size = size
        setupButton()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        _style.configure(with: self)
        _size.configure(with: self)
        _title.configure(with: self)
        _leftIcon.configure(with: self)
        _rightIcon.configure(with: self)
        _isDisabled.configure(with: self)
        
        // UIButton의 기본 요소들을 숨김
        setTitle("", for: .normal)
        setImage(nil, for: .normal)
        
        // iOS 15.0+ Configuration 비활성화
        if #available(iOS 15.0, *) {
            configuration = nil
        }
        
        setupCustomViews()
        updateButtonStyle()
        updateButtonSize()
        updateLayout()
    }
    
    private func setupCustomViews() {
        addSubview(customContainerView)
        customContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        customContainerView.isUserInteractionEnabled = false
        
        customContainerView.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.isUserInteractionEnabled = false

        stackView.addArrangedSubview(leftIconView)
        stackView.addArrangedSubview(customTitleLabel)
        stackView.addArrangedSubview(rightIconView)
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(size.horizontalPadding)
            make.right.lessThanOrEqualToSuperview().offset(-size.horizontalPadding)

            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().offset(size.verticalPadding)
            make.bottom.lessThanOrEqualToSuperview().offset(-size.verticalPadding)
        }
        
        setupIconViews()
        setupTitleLabel()
    }
    
    private func setupIconViews() {
        [leftIconView, rightIconView].forEach { iconView in
            iconView.contentMode = .scaleAspectFit
            iconView.isHidden = true
            iconView.isUserInteractionEnabled = false
            iconView.setContentHuggingPriority(.required, for: .horizontal)
            iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        leftIconView.snp.makeConstraints { make in
            make.width.height.equalTo(size.iconSize.width)
        }

        rightIconView.snp.makeConstraints { make in
            make.width.height.equalTo(size.iconSize.width)
        }
    }

    private func setupTitleLabel() {
        customTitleLabel.textAlignment = .center
        customTitleLabel.numberOfLines = 1
        customTitleLabel.isUserInteractionEnabled = false
        customTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        customTitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    // MARK: - Update Methods
    private func updateButtonState() {
        updateColors()
    }
    
    private func updateButtonStyle() {
        updateColors()
    }
    
    private func updateButtonSize() {
        customTitleLabel.font = size.font
        updateCornerRadius()
        updateIconSizes()
        invalidateIntrinsicContentSize()
    }
    
    private func updateColors() {
        let backgroundColors = style.backgroundColors
        let foregroundColors = style.foregroundColors
        
        backgroundColor = backgroundColors.color(for: currentState)
        let foregroundColor = foregroundColors.color(for: currentState)
        
        customTitleLabel.textColor = foregroundColor
        leftIconView.tintColor = foregroundColor
        rightIconView.tintColor = foregroundColor
    }
    
    private func updateCornerRadius() {
        if size != .rounded {
            layer.cornerRadius = size.cornerRadius
        }
        layer.masksToBounds = true
    }
    
    private func updateIconSizes() {
        let iconSize = size.iconSize.width
        leftIconView.snp.updateConstraints { make in
            make.width.height.equalTo(iconSize)
        }
        rightIconView.snp.updateConstraints { make in
            make.width.height.equalTo(iconSize)
        }
    }
 
    private func updateLayout() {
        stackView.spacing = 0
        stackView.setCustomSpacing(0, after: leftIconView)
        stackView.setCustomSpacing(0, after: customTitleLabel)

        if leftIcon != nil, let title = title, !title.isEmpty {
            stackView.setCustomSpacing(size.iconSpacing, after: leftIconView)
        }

        if rightIcon != nil, let title = title, !title.isEmpty {
            stackView.setCustomSpacing(size.iconSpacing, after: customTitleLabel)
        }
    }
    
    private func updateLeftIcon() {
        if let icon = leftIcon {
            let resizedIcon = icon.resize(to: size.iconSize)
            leftIconView.image = resizedIcon?.withRenderingMode(.alwaysTemplate)
            leftIconView.isHidden = false
        } else {
            leftIconView.image = nil
            leftIconView.isHidden = true
        }
    }
    
    private func updateRightIcon() {
        if let icon = rightIcon {
            let resizedIcon = icon.resize(to: size.iconSize)
            rightIconView.image = resizedIcon?.withRenderingMode(.alwaysTemplate)
            rightIconView.isHidden = false
        } else {
            rightIconView.image = nil
            rightIconView.isHidden = true
        }
    }
    
    // MARK: - Animation
    private func animatePressedState() {
        if isHighlighted {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                usingSpringWithDamping: animationSpringDamping,
                initialSpringVelocity: animationSpringVelocity,
                options: [.allowUserInteraction, .beginFromCurrentState],
                animations: {
                    self.transform = CGAffineTransform(scaleX: self.pressedScale, y: self.pressedScale)
                }
            )
        } else {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                usingSpringWithDamping: animationSpringDamping,
                initialSpringVelocity: animationSpringVelocity,
                options: [.allowUserInteraction, .beginFromCurrentState],
                animations: {
                    self.transform = .identity
                }
            )
        }
    }

    
    // MARK: - Layout
    override public func layoutSubviews() {
        super.layoutSubviews()

        // 'Rounded'일 때만 동적으로 반지름 설정
        if size == .rounded {
            let height = bounds.height
            let width = bounds.width

            let minimumRadius = height / 2
            let dynamicRadius = width / 2

            layer.cornerRadius = min(minimumRadius, dynamicRadius)
        }
        
    }

    public override var intrinsicContentSize: CGSize {
        let stackSize = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        let minimumTotalPadding = size.horizontalPadding * 2
        
        let currentButtonWidth = bounds.width
        let calculatedPadding = max((currentButtonWidth - stackSize.width), minimumTotalPadding)
        
        let intrinsicWidth = stackSize.width + calculatedPadding
        
        if isFullWidth {
            return CGSize(width: UIView.noIntrinsicMetric, height: size.height)
        }
        
        return CGSize(width: intrinsicWidth, height: size.height)
    }

}

// MARK: - Factory Methods
extension BKButton {
    public static func primary(
        title: String,
        size: BKButtonSize = .medium
    ) -> BKButton {
        let button = BKButton(style: .primary, size: size)
        button.title = title
        return button
    }
    
    public static func secondary(
        title: String,
        size: BKButtonSize = .medium
    ) -> BKButton {
        let button = BKButton(style: .secondary, size: size)
        button.title = title
        return button
    }
    
    public static func tertiary(
        title: String,
        size: BKButtonSize = .medium
    ) -> BKButton {
        let button = BKButton(style: .tertiary, size: size)
        button.title = title
        return button
    }
}

// MARK: - Configuration Support
extension BKButton {
    public func configure(with configuration: BKButtonConfiguration) {
        style = configuration.style
        size = configuration.size
        title = configuration.title
        leftIcon = configuration.leftIcon
        rightIcon = configuration.rightIcon
        isDisabled = !configuration.isEnabled
        isFullWidth = configuration.isFullWidth
    }
}

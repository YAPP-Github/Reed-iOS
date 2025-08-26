// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public struct BKDialogConfiguration {
    let leftButtonTitle: String
    let rightButtonTitle: String?
    let leftButtonAction: () -> Void
    let rightButtonAction: (() -> Void)?
    
    public init(
        leftButtonTitle: String,
        leftButtonAction: @escaping () -> Void,
        rightButtonTitle: String? = nil,
        rightButtonAction: (() -> Void)? = nil
    ) {
        self.leftButtonTitle = leftButtonTitle
        self.leftButtonAction = leftButtonAction
        self.rightButtonTitle = rightButtonTitle
        self.rightButtonAction = rightButtonAction
    }
}

public final class BKDialog: UIView {
    public var suppliedContentStyle: SuppliedContentStyle?
    private var contentAspectRatio: CGFloat?
    
    private let titleStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.titleStackSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private let rootStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.rootStackSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private let titleLabel = BKLabel(
        fontStyle: .headline1(
            weight: .semiBold
        ),
        alignment: .center
    )
    
    private let subtitleLabel = BKLabel(
        fontStyle: .body2(weight: .medium),
        color: .bkContentColor(.secondary),
        alignment: .center
    )
    
    private let buttonGroup: BKButtonGroup
    private let titleText: String
    private let subtitleText: String?
    
    let leftButtonAction: () -> Void
    
    public init(
        title: String,
        subtitle: String? = nil,
        config: BKDialogConfiguration,
        suppliedContentStyle: SuppliedContentStyle? = nil
    ) {
        self.titleText = title
        self.subtitleText = subtitle
        self.buttonGroup = Self.makeButtonGroup(config: config)
        self.suppliedContentStyle = suppliedContentStyle
        self.leftButtonAction = config.leftButtonAction
        super.init(frame: .zero)
        
        setup()
        configure()
        layout()
        calculateRatioIfNeeded()
        makeLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BKDialog {
    static func makeButtonGroup(
        config: BKDialogConfiguration
    ) -> BKButtonGroup {
        guard let rightButtonTitle = config.rightButtonTitle,
              let rightButtonAction = config.rightButtonAction
        else {
            return BKButtonGroup.singleFullButton(
                title: config.leftButtonTitle,
                action: config.leftButtonAction
            )
        }
        
        return BKButtonGroup.twoButtonGroup(
            leftTitle: config.leftButtonTitle,
            rightTitle: rightButtonTitle,
            leftAction: config.leftButtonAction,
            rightAction: rightButtonAction
        )
    }
}

private extension BKDialog {
    func setup() {
        addSubviews(rootStack, buttonGroup)
        
        // 타이틀은 항상 추가
        titleStack.addArrangedSubview(titleLabel)
        
        // subtitle이 있을 때만 추가
        if subtitleText != nil {
            titleStack.addArrangedSubview(subtitleLabel)
        }
    }
    
    func configure() {
        layer.cornerRadius = BKRadius.large
        backgroundColor = .bkBaseColor(.primary)
        titleLabel.setText(text: titleText)
        
        if let subtitle = subtitleText, !subtitle.isEmpty {
            subtitleLabel.setText(text: subtitle)
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
        
        titleLabel.numberOfLines = 0
        subtitleLabel.numberOfLines = 0
    }
    
    func layout() {
        rootStack.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(LayoutConstants.titleTopInset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        buttonGroup.snp.makeConstraints {
            $0.top.equalTo(rootStack.snp.bottom)
                .offset(LayoutConstants.buttonTopInset)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(84)
            $0.bottom.equalToSuperview().inset(4)
        }
    }
    
    func makeLayout() {
        switch suppliedContentStyle {
        case .upper(let contentView):
            rootStack.addArrangedSubview(contentView)
            rootStack.addArrangedSubview(titleStack)
            applyRatioIfNeeded(to: contentView)
        case .lower(let contentView):
            rootStack.addArrangedSubview(titleStack)
            rootStack.addArrangedSubview(contentView)
            applyRatioIfNeeded(to: contentView)
        case .none:
            rootStack.addArrangedSubview(titleStack)
        }
    }
    
    func calculateRatioIfNeeded() {
        guard let style = suppliedContentStyle else { return }

        let targetView: UIView
        switch style {
        case .upper(let view), .lower(let view):
            targetView = view
        }

        if let imageView = targetView as? UIImageView,
           let image = imageView.image {
            contentAspectRatio = image.size.height / image.size.width
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    func applyRatioIfNeeded(to view: UIView) {
        if let ratio = contentAspectRatio {
            view.snp.makeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(view.snp.width).multipliedBy(ratio)
            }
        }
    }
}

private extension BKDialog {
    enum LayoutConstants {
        static let titleTopInset = BKInset.inset8
        static let buttonTopInset = BKInset.inset2
        static let horizontalInset = BKInset.inset5
        static let buttonBottomInset = BKInset.inset5
        static let titleStackSpacing = BKSpacing.spacing2
        static let rootStackSpacing = BKSpacing.spacing6
    }
}

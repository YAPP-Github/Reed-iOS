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
    private let titleStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = BKSpacing.spacing2
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
    private let subtitleText: String
    
    public init(
        title: String,
        subtitle: String,
        config: BKDialogConfiguration
    ) {
        self.titleText = title
        self.subtitleText = subtitle
        self.buttonGroup = Self.makeButtonGroup(config: config)
        super.init(frame: .zero)
        
        setup()
        configure()
        layout()
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
        addSubviews(titleStack, buttonGroup)
        [titleLabel, subtitleLabel].forEach(titleStack.addArrangedSubview(_:))
    }
    
    func configure() {
        layer.cornerRadius = BKRadius.large
        backgroundColor = .bkBaseColor(.primary)
        titleLabel.setText(text: titleText)
        subtitleLabel.setText(text: subtitleText)
        
        titleLabel.numberOfLines = 0
        subtitleLabel.numberOfLines = 0
    }
    
    func layout() {
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(LayoutConstants.titleTopInset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        buttonGroup.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom)
                .offset(LayoutConstants.buttonTopInset)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(84)
            $0.bottom.equalToSuperview()
        }
    }
}

private extension BKDialog {
    enum LayoutConstants {
        static let titleTopInset = BKInset.inset8
        static let buttonTopInset = BKInset.inset6
        static let horizontalInset = BKInset.inset5
        static let buttonBottomInset = BKInset.inset5
    }
}

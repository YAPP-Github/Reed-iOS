// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public final class BKBottomSheetTitleView: UIView {
    private let style: BKBottomSheetStyle
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    private let title: String
    private let subtitle: String?
    
    public var onClose: (() -> Void)?
    
    public init(
        style: BKBottomSheetStyle,
        title: String,
        subtitle: String?
    ) {
        self.style = style
        self.title = title
        self.subtitle = subtitle
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BKBottomSheetTitleView {
    func configure() {
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.font = BKTextStyle.heading2(weight: .semiBold).uiFont
        titleLabel.textColor = .bkContentColor(.primary)
        subtitleLabel.textColor = .bkContentColor(.secondary)

        switch style {
        case .leadingCloseButton:
            subtitleLabel.font = BKTextStyle.label2(weight: .regular).uiFont
            closeButton.setImage(BKImage.Icon.x, for: .normal)
            closeButton.tintColor = .bkContentColor(.primary)
            addLeadingLayout(subtitle: subtitle)
        case .centered:
            subtitleLabel.font = BKTextStyle.body1(weight: .medium).uiFont
            addCenteredLayout(subtitle: subtitle)
        }
        
        closeButton.addTarget(
            self,
            action: #selector(didTapCloseButton),
            for: .touchUpInside
        )
    }

    func addLeadingLayout(subtitle: String?) {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.height.equalTo(24)
        }

        if let subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.numberOfLines = 0
            addSubview(subtitleLabel)
            subtitleLabel.snp.makeConstraints {
                $0.leading.equalTo(titleLabel)
                $0.top.equalTo(titleLabel.snp.bottom).offset(2)
                $0.height.equalTo(24)
                $0.bottom.equalToSuperview()
            }
        } else {
            titleLabel.snp.makeConstraints {
                $0.bottom.equalToSuperview()
            }
        }

        addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
        }
    }

    func addCenteredLayout(subtitle: String?) {
        let vStack = UIStackView(arrangedSubviews: [titleLabel])
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 4
        addSubview(vStack)
        vStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleLabel.snp.makeConstraints { $0.height.equalTo(24) }

        if let subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.numberOfLines = 0
            vStack.addArrangedSubview(subtitleLabel)
            subtitleLabel.snp.makeConstraints { $0.height.equalTo(24) }
        }
    }
    
    @objc func didTapCloseButton() {
        onClose?()
    }
}

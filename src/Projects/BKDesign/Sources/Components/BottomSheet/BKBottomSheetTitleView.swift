// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public final class BKBottomSheetTitleView: UIView {
    private let style: BKBottomSheetStyle
    private let titleLabel = BKLabel()
    private let subtitleLabel = BKLabel()
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
        titleLabel.setText(text: title)
        titleLabel.numberOfLines = .zero
        titleLabel.setFontStyle(style: .heading2(weight: .semiBold))
        titleLabel.setColor(color: .bkContentColor(.primary))
        
        if let subtitle = subtitle {
            subtitleLabel.setText(text: subtitle)
            subtitleLabel.numberOfLines = .zero
            subtitleLabel.setColor(color: .bkContentColor(.secondary))
            
            switch style {
            case .leadingCloseButton:
                subtitleLabel.setFontStyle(style: .label2(weight: .regular))
            case .centered:
                subtitleLabel.setFontStyle(style: .body1(weight: .medium))
            }
        }
        
        closeButton.setImage(
            style == .leadingCloseButton
                ? BKImage.Icon.x
                : UIImage(),
            for: .normal
        )
        closeButton.tintColor = .bkContentColor(.primary)
        closeButton.addTarget(
            self,
            action: #selector(didTapCloseButton),
            for: .touchUpInside
        )
        
        switch style {
        case .leadingCloseButton:
            addLeadingLayout()
        case .centered:
            addCenteredLayout()
        }
    }
    
    func addLeadingLayout() {
        let labelStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitle != nil ? subtitleLabel : nil
        ].compactMap { $0 })
        labelStack.axis = .vertical
        labelStack.alignment = .leading
        labelStack.spacing = LayoutConstants.leadingContentSpacing
        
        let hStack = UIStackView(arrangedSubviews: [labelStack, closeButton])
        hStack.axis = .horizontal
        hStack.alignment = .top
        hStack.spacing = LayoutConstants.leadingContentSpacing
        
        addSubview(hStack)
        hStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        closeButton.setContentHuggingPriority(.required, for: .horizontal)
        closeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func addCenteredLayout() {
        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center
        
        let vStack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitle != nil ? subtitleLabel : nil
        ].compactMap { $0 })
        vStack.axis = .vertical
        vStack.alignment = .fill
        vStack.spacing = LayoutConstants.centeredContentSpacing
        
        addSubview(vStack)
        vStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    @objc func didTapCloseButton() {
        onClose?()
    }
}

private extension BKBottomSheetTitleView {
    enum LayoutConstants {
        static let leadingContentSpacing: CGFloat = 2
        static let centeredContentSpacing: CGFloat = 4
        static let labelHeight: CGFloat = 24
    }
}

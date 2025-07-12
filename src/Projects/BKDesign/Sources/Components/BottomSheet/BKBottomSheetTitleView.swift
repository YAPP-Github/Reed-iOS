// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public final class BKBottomSheetTitleView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let closeButton = UIButton()
    
    private let titleView = UIView()
    private let vStack = UIStackView()
    
    public var onClose: (() -> Void)?
    
    public init(style: BKBottomSheetTitleStyle) {
        super.init(frame: .zero)
        setupBaseUI()
        setAction()
        
        apply(style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBaseUI() {
        closeButton.tintColor = .bkContentColor(.primary)
        closeButton.snp.makeConstraints {
            $0.height.width.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(28)
        }
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        closeButton.setContentHuggingPriority(.required, for: .horizontal)
        
        vStack.axis = .vertical
        vStack.spacing = BKSpacing.spacing05
        vStack.alignment = .leading
        
        setupFontStyle()
        closeButton.setImage(BKImage.Icon.x, for: .normal)
        
        addSubview(vStack)
        vStack.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(BKSpacing.spacing5)
        }
    }
    
    private func setAction() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
    }
    
    private func setupFontStyle() {
        titleLabel.font = BKTextStyle.heading2(weight: .semiBold).uiFont ??
            .systemFont(
                ofSize: BKTextStyle.heading2(weight: .semiBold).fontAttributes.fontSize.rawValue,
                weight: .semibold
            )
        titleLabel.textColor = .bkContentColor(.primary)
        
        subtitleLabel.font = BKTextStyle.label2(weight: .regular).uiFont ??
            .systemFont(
                ofSize: BKTextStyle.label2(weight: .regular).fontAttributes.fontSize.rawValue,
                weight: .regular
            )
        subtitleLabel.textColor = .bkContentColor(.secondary)
    }
    
    public func apply(_ style: BKBottomSheetTitleStyle) {
        titleView.subviews.forEach { $0.removeFromSuperview() }
        vStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        switch style {
        case .none:
            vStack.snp.makeConstraints { make in
                make.height.equalTo(0)
            }
            
        case let .title(title):
            setupTitleLabel(title)
            
        case let .titleWithCloseButton(title):
            setupTitleView(title)
            
        case let .titleWithSubtitle(title, subtitle):
            setupTitleLabel(title)
            setupSubTitleLabel(subtitle)
            
        case let .titleWithSubtitleAndCloseButton(title, subtitle):
            setupTitleView(title)
            setupSubTitleLabel(subtitle)
        }
    }
    
    private func setupTitleView(_ title: String) {
        titleLabel.text = title
        
        [titleLabel, closeButton].forEach { titleView.addSubview($0) }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(BKSpacing.spacing4)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        
        vStack.addArrangedSubview(titleView)
        titleView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(28)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupTitleLabel(_ title: String) {
        titleLabel.text = title
        vStack.addArrangedSubview(titleLabel)
    }
    
    private func setupSubTitleLabel(_ subtitle: String) {
        subtitleLabel.text = subtitle
        vStack.addArrangedSubview(subtitleLabel)
    }
    
    @objc
    private func didTapClose() {
        onClose?()
    }
}

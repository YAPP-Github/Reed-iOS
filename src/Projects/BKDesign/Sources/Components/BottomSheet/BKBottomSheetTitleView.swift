// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public final class BKBottomSheetTitleView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let closeButton = UIButton()
    
    private let hStack = UIStackView()
    private let vStack = UIStackView()
    
    public init(style: BKBottomSheetTitleStyle) {
        super.init(frame: .zero)
        setupBaseUI()
        apply(style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBaseUI() {
        vStack.axis = .vertical
        vStack.spacing = BKSpacing.spacing05
        vStack.alignment = .leading
        
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.distribution = .fill
        hStack.spacing = BKSpacing.spacing4
        
        setupFontStyle()
        closeButton.setImage(BKIcon.xmark.image, for: .normal)
        
        addSubview(hStack)
        hStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(BKSpacing.spacing5)
        }
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
        hStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        vStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // case 별 분류..
    }
}

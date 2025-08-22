// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class SettingCell: UICollectionViewListCell {
    enum SettingCellStyle {
        case chevron
        case label
        case none
    }
    
    static let identifier = "SettingCell"
    
    private let titleLabel = BKLabel()
    private let versionLabel = BKLabel(
        fontStyle: .body1(weight: .medium),
        color: .bkContentColor(.brand)
    )
    
    private let recentVersionLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.tertiary)
    )
    
    private let iconView: UIImageView = {
        let view = UIImageView(image: BKImage.Icon.chevronRight)
        view.tintColor = .bkContentColor(.secondary)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = .bkBaseColor(.primary)
            contentView.backgroundColor = .bkBaseColor(.primary)
        }
    }
    
    private var style: SettingCellStyle = .none
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .bkBaseColor(.primary)
        contentView.backgroundColor = .bkBaseColor(.primary)
        contentView.addSubviews(titleLabel, recentVersionLabel, iconView, versionLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
                .inset(BKInset.inset5)
        }
        
        recentVersionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
                .inset(BKInset.inset5)
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.bottom.equalToSuperview().inset(BKInset.inset4)
        }

        iconView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(BKInset.inset5)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(BKLayoutSize.icon)
        }

        versionLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(BKInset.inset5)
            $0.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)

        if style == .label {
            attrs.frame.size.height = BKLayoutSize.Height.versionCell
        } else {
            attrs.frame.size.height = BKLayoutSize.Height.cell
        }
        
        return attrs
    }
    
    private func updateLayoutForStyle() {
        titleLabel.snp.remakeConstraints {
            $0.leading.equalToSuperview().inset(BKInset.inset5)
            
            if style == .label {
                $0.top.equalToSuperview().inset(BKInset.inset4)
            } else {
                $0.centerY.equalToSuperview()
            }
        }
    }
    
    func configure(
        title: String,
        style: SettingCellStyle = .chevron,
        recentVersion: String? = nil,
        appVersion: String? = nil
    ) {
        self.style = style
        updateLayoutForStyle()
        
        titleLabel.setText(text: title)
        
        switch style {
        case .chevron:
            iconView.isHidden = false
            versionLabel.isHidden = true
            recentVersionLabel.isHidden = true
        case .label:
            iconView.isHidden = true
            versionLabel.isHidden = false
            recentVersionLabel.isHidden = false
            recentVersionLabel.setText(text: "최신 버전 \(recentVersion ?? "-")")
            versionLabel.setText(text: appVersion ?? "-")
        case .none:
            iconView.isHidden = true
            versionLabel.isHidden = true
            recentVersionLabel.isHidden = true
        }
    }
}

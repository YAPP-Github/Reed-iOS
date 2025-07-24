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
        color: .bkContentColor(
            .secondary
        )
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .bkBaseColor(.primary)
        contentView.backgroundColor = .bkBaseColor(.primary)
        [titleLabel, iconView, versionLabel].forEach(addSubview(_:))
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
                .inset(BKInset.inset5)
            $0.centerY.equalToSuperview()
        }

        iconView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(BKInset.inset4)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(BKLayoutSize.icon)
        }

        versionLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(BKInset.inset4)
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
        attrs.frame.size.height = BKLayoutSize.Height.cell
        return attrs
    }
    
    func configure(
        title: String,
        style: SettingCellStyle = .chevron,
        appVersion: String? = nil
    ) {
        titleLabel.setText(text: title)
        
        switch style {
        case .chevron:
            iconView.isHidden = false
            versionLabel.isHidden = true
        case .label:
            iconView.isHidden = true
            versionLabel.isHidden = false
            versionLabel.setText(text: appVersion ?? "-")
        case .none:
            iconView.isHidden = true
            versionLabel.isHidden = true
        }
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class TermsItemCell: UICollectionViewListCell {
    static let identifier: String = "TermsItemCell"
    
    // MARK: - Layout Metrics
    enum LayoutGuide {
        static let iconSize: CGFloat = 24
        static let checkBoxInteractionSize: CGFloat = 44
        static let horizontalPadding: CGFloat = BKSpacing.spacing1
    }
    
    // MARK: - UI Components
    private let checkBoxInteractionView = UIView()
    private let checkBox = BKCheckBox(frame: .zero, type: .roundStroke)
    
    private let titleLabel = BKLabel(fontStyle: .body1(weight: .medium))
    
    private let chevronIconView: UIImageView = {
        let view = UIImageView(image: BKImage.Icon.chevronRight)
        view.contentMode = .scaleAspectFit
        view.tintColor = .bkContentColor(.secondary)
        view.isHidden = true
        return view
    }()
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
        attrs.frame.size.height = BKLayoutSize.Height.termsCell
        return attrs
    }
    
    private func setupView() {
        checkBoxInteractionView.addSubview(checkBox)
        
        checkBox.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(LayoutGuide.iconSize)
        }
        
        addSubviews(checkBoxInteractionView, titleLabel, chevronIconView)
        
        checkBoxInteractionView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.height.width.equalTo(LayoutGuide.checkBoxInteractionSize)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkBoxInteractionView.snp.trailing).offset(LayoutGuide.horizontalPadding)
            $0.centerY.equalToSuperview()
        }
        
        chevronIconView.snp.makeConstraints {
            $0.width.height.equalTo(LayoutGuide.iconSize)
            $0.trailing.equalToSuperview().inset(BKSpacing.spacing3)
            $0.centerY.equalToSuperview()
        }
    }
    
    public func configure(_ vo: TermsViewObject) {
        titleLabel.setText(text: vo.title)
        
        if vo.URL != nil {
            chevronIconView.isHidden = false
        }
    }

}


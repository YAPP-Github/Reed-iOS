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
    private let checkBox = UIImageView(image: BKImage.Icon.check)
    
    private let titleLabel = BKLabel(fontStyle: .body1(weight: .medium))
    
    private let chevronIconView: UIImageView = {
        let view = UIImageView(image: BKImage.Icon.chevronRight)
        view.contentMode = .scaleAspectFit
        view.tintColor = .bkContentColor(.secondary)
        view.isHidden = true
        return view
    }()
    
    // MARK: - Callbacks
    /// 체크박스 영역이 탭 되었을 때 호출될 클로저
    var onCheckTapped: (() -> Void)?
    /// 상세보기(chevron) 아이콘이 탭 되었을 때 호출될 클로저
    var onDetailTapped: (() -> Void)?
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        backgroundColor = .bkBaseColor(.primary)
        titleLabel.setText(text: "")
        chevronIconView.isHidden = true
        
        onCheckTapped = nil
        onDetailTapped = nil
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
    
    public func configure(_ term: Term) {
        titleLabel.setText(text: term.title)
        contentView.backgroundColor = .bkBaseColor(.primary)

        checkBox.tintColor = term.isAgreed ? .bkContentColor(.brand) : .bkContentColor(.tertiary)
        chevronIconView.isHidden = (term.url == nil)
    }
    
    private func setupActions() {
        let checkTap = UITapGestureRecognizer(target: self, action: #selector(handleCheckTap))
        checkBoxInteractionView.addGestureRecognizer(checkTap)
        
        let detailTap = UITapGestureRecognizer(target: self, action: #selector(handleDetailTap))
        chevronIconView.addGestureRecognizer(detailTap)
        chevronIconView.isUserInteractionEnabled = true
    }
    
    @objc private func handleCheckTap() {
        onCheckTapped?()
    }
    
    @objc private func handleDetailTap() {
        onDetailTapped?()
    }

}

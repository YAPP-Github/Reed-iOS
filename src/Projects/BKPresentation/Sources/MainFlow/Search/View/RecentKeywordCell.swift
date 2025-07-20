// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class RecentKeywordCell: UICollectionViewCell {
    static let identifier: String = "RecentKeywordCell"
    
    private let searchQueryLabel = BKLabel(
        color: .bkContentColor(.secondary),
        alignment: .left
    )
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(BKImage.Icon.x, for: .normal)
        button.tintColor = .bkContentColor(.secondary)
        return button
    }()
    
    var onQueryLabelTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(searchQueryLabel, deleteButton)
        
        searchQueryLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.labelLeadingInset)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.labelTrailingInset)
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.deleteButtonTrailingInset)
            $0.size.equalTo(
                CGSize(
                    width: LayoutConstants.iconSize,
                    height: LayoutConstants.iconSize
                )
            )
        }
        
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        searchQueryLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapQueryLabel))
        searchQueryLabel.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(labelText text: String) {
        self.searchQueryLabel.setText(text: text)
    }
}

private extension RecentKeywordCell {
    @objc func didTapDeleteButton() {
        onDeleteTapped?()
    }
    
    @objc func didTapQueryLabel() {
        onQueryLabelTapped?()
    }
    
    enum LayoutConstants {
        static let labelLeadingInset = BKInset.inset6
        static let labelTrailingInset: CGFloat = 50
        static let deleteButtonTrailingInset = BKInset.inset5
        static let iconSize: CGFloat = 18
    }
}

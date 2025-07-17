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
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(BKImage.Icon.x, for: .normal)
        button.tintColor = .bkContentColor(.secondary)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(searchQueryLabel, clearButton)
        
        searchQueryLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.leadingInset)
        }
        
        clearButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.trailingInset)
            $0.size.equalTo(
                CGSize(
                    width: LayoutConstants.iconSize,
                    height: LayoutConstants.iconSize
                )
            )
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(labelText text: String) {
        self.searchQueryLabel.setText(text: text)
    }
}

private extension RecentKeywordCell {
    enum LayoutConstants {
        static let leadingInset = BKInset.inset6
        static let trailingInset = BKInset.inset5
        static let iconSize = 18
    }
}

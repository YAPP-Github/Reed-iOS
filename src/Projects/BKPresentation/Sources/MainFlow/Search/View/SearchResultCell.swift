// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class SearchResultCell: UICollectionViewCell {
    static let identifier = "SearchResultCell"
    
    private let thumbnail = UIImageView()
    private let labelStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.labelStackSpacing
        stackView.alignment = .leading
        return stackView
    }()
    
    private let titleLabel = BKLabel(fontStyle: .body1(weight: .semiBold))
    private let descriptionLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.disable)
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(titleLabel, labelStack)
        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(descriptionLabel)
        
        thumbnail.snp.makeConstraints {
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(LayoutConstants.thumbnailSize)
        }
        
        labelStack.snp.makeConstraints {
            $0.leading.equalTo(thumbnail.snp.trailing)
                .offset(LayoutConstants.labelStackOffset)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        title: String,
        description: String,
        image: UIImage
    ) {
        titleLabel.setText(text: title)
        descriptionLabel.setText(text: description)
        thumbnail.image = image
    }
}

private extension SearchResultCell {
    enum LayoutConstants {
        static let thumbnailSize: CGSize = CGSize(
            width: 68,
            height: 100
        )
        static let labelStackOffset: CGFloat = BKInset.inset4
        static let labelStackSpacing: CGFloat = BKSpacing.spacing1
        static let horizontalInset: CGFloat = BKInset.inset5
    }
}

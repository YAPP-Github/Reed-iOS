// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Kingfisher
import SnapKit
import UIKit

final class SearchResultCell: UICollectionViewCell {
    static let identifier = "SearchResultCell"
    
    struct BookDescription {
        let author: String
        let publisher: String
    }
    
    private let thumbnail = UIImageView()
    private let labelStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.labelStackSpacing
        stackView.alignment = .leading
        return stackView
    }()
    
    private let titleLabel = BKLabel(fontStyle: .body1(weight: .semiBold))
    private let authorLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.disable)
    )
    
    private let separatorLabel = BKLabel(
        text: " | ",
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.disable)
    )
    
    private let publisherLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.disable)
    )
    
    private let dividerView = BKDivider(type: .small)
    
    private let descriptionStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = .zero
        stackView.alignment = .leading
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(thumbnail, labelStack, dividerView)
        [titleLabel, descriptionStack].forEach(labelStack.addArrangedSubview(_:))
        [authorLabel, separatorLabel, publisherLabel].forEach(descriptionStack.addArrangedSubview(_:))
        
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
        
        authorLabel.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(descriptionStack.snp.width)
                .multipliedBy(LayoutConstants.authorMaxRatio)
        }
        
        dividerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        authorLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        authorLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        separatorLabel.setContentHuggingPriority(.required, for: .horizontal)
        separatorLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        publisherLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        publisherLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
        titleLabel.setText(text: "")
        authorLabel.setText(text: "")
        publisherLabel.setText(text: "")
    }
    
    func configure(
        title: String,
        description: BookDescription,
        image: URL?
    ) {
        titleLabel.numberOfLines = 1
        authorLabel.numberOfLines = 1
        titleLabel.setText(text: title)
        authorLabel.setText(text: description.author)
        publisherLabel.setText(text: description.publisher)
        titleLabel.lineBreakMode = .byTruncatingTail
        authorLabel.lineBreakMode = .byTruncatingTail
        
        if let image {
            thumbnail.kf.setImage(with: image)
        } else {
            thumbnail.kf.setImage(with: URL(string: "https://placehold.co/68x100"))
        }
        
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
        static let authorMaxRatio: CGFloat = 0.65
    }
}

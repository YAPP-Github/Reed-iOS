// Copyright © 2025 Booket. All rights reserved

import Kingfisher
import SnapKit
import UIKit

public enum BKBookSummaryViewStyle {
    case regular
    case compact
    
    var thumbnailSize: CGSize {
        switch self {
        case .regular: return CGSize(width: 68, height: 100)
        case .compact: return CGSize(width: 46, height: 68)
        }
    }
    
    var placeholderImage: URL? {
        switch self {
        case .regular: return URL(string: "https://dummyimage.com/68x100/2f9647/ffffff")
        case .compact: return URL(string: "https://dummyimage.com/46x68/2f9647/ffffff")
        }
    }
}

/// 해당 View는 intrinsicContentSize가 없습니다.
/// 사용되는 곳에 따라서 Height이 계속 바뀌므로 사용 시 Constraints를 잘 설정하거나, Size를 명시적으로 제공하세요.
public class BKBookSummaryView: UIView {
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
    
    private let descriptionStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = .zero
        stackView.alignment = .leading
        return stackView
    }()
    
    private let style: BKBookSummaryViewStyle
    
    public init(
        frame: CGRect = .zero,
        style: BKBookSummaryViewStyle = .regular
    ) {
        self.style = style
        super.init(frame: frame)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(
        title: String,
        author: String,
        publisher: String,
        image: URL? = nil
    ) {
        titleLabel.numberOfLines = 1
        authorLabel.numberOfLines = 1
        titleLabel.setText(text: title)
        authorLabel.setText(text: author)
        publisherLabel.setText(text: publisher)
        titleLabel.lineBreakMode = .byTruncatingTail
        authorLabel.lineBreakMode = .byTruncatingTail
        
        if let image {
            thumbnail.kf.setImage(with: image)
        } else {
            thumbnail.kf.setImage(with: style.placeholderImage)
        }
        
        thumbnail.clipsToBounds = true
        thumbnail.layer.masksToBounds = true
        thumbnail.layer.cornerRadius = LayoutConstants.imageRadius
    }
    
    public func clearView() {
        thumbnail.image = nil
        titleLabel.setText(text: "")
        authorLabel.setText(text: "")
        publisherLabel.setText(text: "")
    }
}

private extension BKBookSummaryView {
    func setup() {
        addSubviews(thumbnail, labelStack)
        [titleLabel, descriptionStack].forEach(labelStack.addArrangedSubview(_:))
        [authorLabel, separatorLabel, publisherLabel].forEach(descriptionStack.addArrangedSubview(_:))
    }
    
    func layout() {
        thumbnail.snp.makeConstraints {
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(style.thumbnailSize)
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
        
        authorLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        authorLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        separatorLabel.setContentHuggingPriority(.required, for: .horizontal)
        separatorLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        publisherLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        publisherLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
}

private extension BKBookSummaryView {
    enum LayoutConstants {
        static let labelStackOffset: CGFloat = BKInset.inset4
        static let labelStackSpacing: CGFloat = BKSpacing.spacing1
        static let horizontalInset: CGFloat = BKInset.inset5
        static let authorMaxRatio: CGFloat = 0.65
        static let imageRadius = BKRadius.xsmall
    }
}

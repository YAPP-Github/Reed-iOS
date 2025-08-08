// Copyright © 2025 Booket. All rights reserved

import Kingfisher
import SnapKit
import UIKit

public enum BKBookSummaryViewStyle {
    case regular
    case compact
    case big
    case record
    case alreadyEnroll

    var thumbnailSize: CGSize {
        switch self {
        case .regular, .big, .record, .alreadyEnroll:
            return CGSize(width: 68, height: 100)
        case .compact:
            return CGSize(width: 46, height: 68)
        }
    }

    var placeholderImage: URL? {
        switch self {
        case .regular, .big, .record, .alreadyEnroll:
            return URL(string: "https://dummyimage.com/68x100/2f9647/ffffff")
        case .compact:
            return URL(string: "https://dummyimage.com/46x68/2f9647/ffffff")
        }
    }

    var labelStackSpacing: CGFloat {
        switch self {
        case .regular, .compact, .record, .alreadyEnroll:
            return BKSpacing.spacing1
        case .big:
            return BKSpacing.spacing2
        }
    }

    var showsExtraLabel: Bool { self == .big }
    var extraLabelTopOffset: CGFloat { showsExtraLabel ? BKInset.inset05 : .zero }
    var titleLabelNumberOfLines: Int { showsExtraLabel ? 2 : 1 }
}

public class BKBookSummaryView: UIView {
    private let thumbnail = UIImageView()
    private let labelStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()
    
    private let titleLabel = BKLabel(fontStyle: .body1(weight: .semiBold))
    private let descriptionStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = .zero
        stackView.alignment = .leading
        return stackView
    }()
    private let authorLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.disable)
    )
    private let separatorLabel = BKLabel(
        text: " | ",
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(
            .disable
        )
    )
    private let publisherLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.disable)
    )
    private let extraLabel = BKLabel(
        fontStyle: .label1(weight: .regular),
        color: .bkContentColor(.disable)
    )

    // Record mode views
    private let recordView = UIView()
    private let recordLabel = BKLabel(
        text: "남긴 기록",
        fontStyle: .label2(weight: .regular),
        color: .bkContentColor(
            .primary
        )
    )
    private let recordCountLabel = BKLabel(
        fontStyle: .label2(weight: .semiBold),
        color: .bkContentColor(.brand)
    )

    // Already Record mode views
    private let guideLabel = BKLabel(
        text: "이미 등록된 책입니다",
        fontStyle: .label2(weight: .regular),
        color: .bkContentColor(.success)
    )
    private let style: BKBookSummaryViewStyle

    public init(frame: CGRect = .zero, style: BKBookSummaryViewStyle = .regular) {
        self.style = style
        super.init(frame: frame)
        setupViews()
        setupLayouts()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        authorLabel.lineBreakMode = .byTruncatingTail
        publisherLabel.lineBreakMode = .byTruncatingTail
        
        addSubviews(thumbnail, labelStack)
        labelStack.spacing = style.labelStackSpacing
        labelStack.addArrangedSubview(titleLabel)
        
        switch style {
        case .record:
            labelStack.addArrangedSubview(descriptionStack)
            labelStack.addArrangedSubview(recordView)
            
            recordView.addSubviews(recordLabel, recordCountLabel)
            descriptionStack.addArrangedSubview(authorLabel)
            descriptionStack.addArrangedSubview(separatorLabel)
            descriptionStack.addArrangedSubview(publisherLabel)
            labelStack.setCustomSpacing(BKSpacing.spacing3, after: descriptionStack)
            
        case .alreadyEnroll:
            labelStack.removeArrangedSubview(titleLabel)
            descriptionStack.addArrangedSubview(authorLabel)
            descriptionStack.addArrangedSubview(separatorLabel)
            descriptionStack.addArrangedSubview(publisherLabel)
            
            /// style setting
            self.backgroundColor = .bkBackgroundColor(.disable)
            thumbnail.backgroundColor = UIColor(hex: "000000").withAlphaComponent(0.4)

            [titleLabel, authorLabel, separatorLabel, publisherLabel].forEach {
                $0.setColor(color: .bkContentColor(.disable))
            }
            
            [guideLabel, titleLabel, descriptionStack].forEach {
                labelStack.addArrangedSubview($0)
            }
            
        default:
            let descriptionBlock = UIStackView(arrangedSubviews: [descriptionStack])
            descriptionBlock.axis = .vertical
            descriptionBlock.alignment = .leading
            descriptionBlock.spacing = 0

            descriptionStack.addArrangedSubview(authorLabel)
            descriptionStack.addArrangedSubview(separatorLabel)
            descriptionStack.addArrangedSubview(publisherLabel)
            labelStack.addArrangedSubview(descriptionBlock)

            if style.showsExtraLabel {
                descriptionBlock.addArrangedSubview(extraLabel)
                descriptionBlock.setCustomSpacing(style.extraLabelTopOffset, after: descriptionStack)
            }
        }

        authorLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        authorLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        separatorLabel.setContentHuggingPriority(.required, for: .horizontal)
        separatorLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        publisherLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        publisherLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    private func setupLayouts() {
        thumbnail.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(LayoutConstants.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(style.thumbnailSize)
        }

        labelStack.snp.makeConstraints {
            $0.leading.equalTo(thumbnail.snp.trailing).offset(LayoutConstants.labelStackOffset)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(LayoutConstants.horizontalInset)
        }

        titleLabel.numberOfLines = style.titleLabelNumberOfLines
        titleLabel.lineBreakMode = .byTruncatingTail

        switch style {
        case .record:
            recordLabel.snp.makeConstraints {
                $0.leading.top.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
            recordCountLabel.snp.makeConstraints {
                $0.leading.equalTo(recordLabel.snp.trailing).offset(LayoutConstants.labelStackSpacing)
                $0.centerY.equalTo(recordLabel)
            }
        default:
            break
        }
    }

    public func configure(
        title: String,
        author: String,
        publisher: String,
        extraText: String? = nil,
        recordCount: Int? = nil,
        image: URL? = nil
    ) {
        titleLabel.setText(text: title)
        authorLabel.setText(text: author)
        publisherLabel.setText(text: publisher)
        thumbnail.clipsToBounds = true
        thumbnail.layer.cornerRadius = LayoutConstants.imageRadius
        if let imageURL = image {
            thumbnail.kf.setImage(with: imageURL)
        } else {
            thumbnail.kf.setImage(with: style.placeholderImage)
        }

        if style == .record {
            if let count = recordCount {
                recordCountLabel.setText(text: "\(count)")
                recordView.isHidden = false
            } else {
                recordView.isHidden = true
            }
        } else if style.showsExtraLabel, let text = extraText {
            extraLabel.setText(text: text)
        }
    }

    public func clearView() {
        thumbnail.image = nil
        titleLabel.setText(text: "")
        authorLabel.setText(text: "")
        publisherLabel.setText(text: "")
        extraLabel.setText(text: "")
        recordCountLabel.setText(text: "")
    }
}

private extension BKBookSummaryView {
    enum LayoutConstants {
        static let horizontalInset: CGFloat = BKInset.inset5
        static let labelStackOffset: CGFloat = BKInset.inset4
        static let labelStackSpacing: CGFloat = BKSpacing.spacing1
        static let imageRadius: CGFloat = BKRadius.xsmall
    }
}

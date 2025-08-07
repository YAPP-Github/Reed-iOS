// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Kingfisher
import SnapKit
import UIKit

final class HomeCardCell: UICollectionViewCell {
    public static let reuseIdentifier = "HomeCardCell"
    
    private var onNoteButtonTapped: (() -> Void)?
    
    private let containerView = UIView()
    private let thumbnail = UIImageView()
    
    private let titleLabel = BKLabel(
        fontStyle: .headline1(weight: .semiBold),
        alignment: .center
    )
    
    private let authorLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.disable),
        alignment: .right
    )
    
    private let separatorLabel = BKLabel(
        text: "|",
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.disable),
        alignment: .center
    )
    
    private let publisherLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.disable),
        alignment: .left
    )
    
    private let descriptionStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let recordCountView = RecordCountView()
    private let addNoteButton = BKButton(style: .primary, size: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
        thumbnail.kf.cancelDownloadTask()
    }
    
    func configure(
        title: String,
        author: String,
        publisher: String,
        recordCount: Int,
        image: URL? = nil,
        onNoteButtonTapped: @escaping () -> Void
    ) {
        self.onNoteButtonTapped = onNoteButtonTapped
        
        titleLabel.numberOfLines = 1
        authorLabel.numberOfLines = 1
        
        titleLabel.setText(text: title)
        authorLabel.setText(text: author)
        publisherLabel.setText(text: publisher)
        
        titleLabel.lineBreakMode = .byTruncatingTail
        authorLabel.lineBreakMode = .byTruncatingTail
        publisherLabel.lineBreakMode = .byTruncatingTail
        
        recordCountView.configure(count: recordCount)
        
        if let image {
            thumbnail.kf.setImage(with: image)
        } else {
            thumbnail.tintColor = .gray
        }
        
        thumbnail.clipsToBounds = true
        thumbnail.layer.masksToBounds = true
        thumbnail.layer.cornerRadius = BKRadius.xsmall
    }
    
    func setupView() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        contentView.addSubview(containerView)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = BKRadius.medium
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = LayoutConstants.shadowOffset
        containerView.layer.shadowRadius = LayoutConstants.shadowRadius
        containerView.layer.shadowOpacity = LayoutConstants.shadowOpacity
        containerView.layer.masksToBounds = false
        
        titleLabel.numberOfLines = 1
        authorLabel.numberOfLines = 1
        
        titleLabel.lineBreakMode = .byTruncatingTail
        authorLabel.lineBreakMode = .byTruncatingTail
        publisherLabel.lineBreakMode = .byTruncatingTail
        
        addNoteButton.leftIcon = BKImage.Icon.edit3
        addNoteButton.title = "기록하기"
        
        containerView.addSubviews(
            thumbnail,
            titleLabel,
            descriptionStack,
            recordCountView,
            addNoteButton
        )
        
        [authorLabel, separatorLabel, publisherLabel].forEach { label in
            descriptionStack.addArrangedSubview(label)
            
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        setupConstraints()
        addNoteButton.addTarget(self, action: #selector(handleNoteButtonTap), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
                .inset(LayoutConstants.containerInset)
        }
        
        thumbnail.snp.makeConstraints {
            $0.top.equalToSuperview().inset(LayoutConstants.thumbnailTopSpacing)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(LayoutConstants.thumbnailSize.width)
            $0.height.equalTo(LayoutConstants.thumbnailSize.height)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnail.snp.bottom).offset(LayoutConstants.titleTopSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.sidePadding)
        }
        
        authorLabel.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(120)
        }

        separatorLabel.snp.makeConstraints {
            $0.width.equalTo(5)
        }

        publisherLabel.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(120)
        }
        
        descriptionStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(LayoutConstants.despStackTopSpacing)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.greaterThanOrEqualToSuperview()
                .inset(LayoutConstants.sidePadding)
        }
        
        recordCountView.snp.makeConstraints {
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.sidePadding)
            $0.bottom.equalToSuperview()
                .inset(LayoutConstants.bottomPadding)
            $0.height.equalTo(LayoutConstants.recordCountHeight)
        }
        
        addNoteButton.snp.makeConstraints {
            $0.leading.equalTo(recordCountView.snp.trailing)
                .offset(LayoutConstants.recordCountSpacing)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.sidePadding)
            $0.centerY.equalTo(recordCountView)
        }

    }
    
    @objc private func handleNoteButtonTap() {
        onNoteButtonTapped?()
    }
}

private extension HomeCardCell {
    enum LayoutConstants {
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let shadowRadius: CGFloat = 8
        static let shadowOpacity: Float = 0.1
        static let containerInset = UIEdgeInsets(top: 12, left: 0, bottom: 20, right: 0)
        static let sidePadding: CGFloat = 20
        static let bottomPadding: CGFloat = 20
        static let recordCountHeight: CGFloat = 46
        static let recordCountSpacing: CGFloat = 12
        static let buttonTopSpacing: CGFloat = 24
        static let despStackTopSpacing: CGFloat = 4
        
        static let titleTopSpacing: CGFloat = 16
        static let thumbnailTopSpacing: CGFloat = 32
        static let thumbnailSize = CGSize(width: 95.6, height: 140)
    }
}

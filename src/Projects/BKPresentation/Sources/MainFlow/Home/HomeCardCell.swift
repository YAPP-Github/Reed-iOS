// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Kingfisher
import SnapKit
import UIKit

final class HomeCardCell: UICollectionViewCell {
    public static let reuseIdentifier = "HomeCardCell"
    
    private let containerView = UIView()
    private let thumbnail = UIImageView()
    
    private let titleLabel = BKLabel(
        fontStyle: .headline1(weight: .semiBold),
        alignment: .center
    )
    
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
    
    func setupView() {
        contentView.addSubview(containerView)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = BKRadius.medium
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.masksToBounds = false
        
        titleLabel.numberOfLines = 1
        authorLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        authorLabel.lineBreakMode = .byTruncatingTail
        
        addNoteButton.leftIcon = BKImage.Icon.edit3
        addNoteButton.title = "기록하기"
        
        containerView.addSubviews(
            thumbnail,
            titleLabel,
            descriptionStack,
            recordCountView,
            addNoteButton
        )
        
        [authorLabel, separatorLabel, publisherLabel].forEach(descriptionStack.addArrangedSubview(_:))
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // 컨테이너 뷰
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        }
        
        // 하단 버튼 먼저 설정 (고정 위치)
        recordCountView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        addNoteButton.snp.makeConstraints {
            $0.leading.equalTo(recordCountView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(recordCountView)
        }
        
        descriptionStack.snp.makeConstraints {
            $0.bottom.equalTo(addNoteButton.snp.top).offset(-24)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(descriptionStack.snp.top).offset(-4)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        thumbnail.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel.snp.top).offset(-24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(86)
            $0.height.equalTo(125)
            $0.top.greaterThanOrEqualToSuperview().inset(24)
        }
    }
    
    public func configure(
        title: String,
        author: String,
        publisher: String,
        recordCount: Int,
        image: URL? = nil
    ) {
        titleLabel.numberOfLines = 1
        authorLabel.numberOfLines = 1
        
        titleLabel.setText(text: title)
        authorLabel.setText(text: author)
        publisherLabel.setText(text: publisher)
        
        titleLabel.lineBreakMode = .byTruncatingTail
        authorLabel.lineBreakMode = .byTruncatingTail
        
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
}

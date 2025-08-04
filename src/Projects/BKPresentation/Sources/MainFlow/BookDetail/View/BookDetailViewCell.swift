// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class BookDetailViewCell: UICollectionViewCell {
    static let reuseIdentifier: String = "BookDetailViewCell"
    
    private let noteLabel = BKLabel(
        fontStyle: .body2(weight: .medium),
        color: .bkContentColor(.secondary)
    )
    
    private let lowerStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let emotionIcon = UIImageView()
    private let emotionLabel = BKLabel(
        fontStyle: .body2(weight: .medium),
        color: .bkContentColor(.brand)
    )
    
    private let creationLabel = BKLabel(
        fontStyle: .caption1(weight: .regular),
        color: .bkContentColor(.tertiary)
    )
    
    private let emotionLabelStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    private let pageLabel = BKLabel(
        fontStyle: .body2(weight: .medium),
        color: .bkContentColor(.brand)
    )
    
    private let emotionStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = LayoutConstants.emotionStackSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configure()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        noteLabel.setText(text: "")
        emotionIcon.image = nil
        emotionLabel.setText(text: "")
        creationLabel.setText(text: "")
        pageLabel.setText(text: "")
    }
    
    func configure(
        with item: BookDetailItem
    ) {
        noteLabel.setText(text: item.note)
        emotionIcon.image = item.emotion.image
        emotionIcon.layer.cornerRadius = LayoutConstants.imageCornerRadius
        emotionIcon.clipsToBounds = true
        emotionLabel.setText(text: "#\(item.emotion.rawValue)")
        creationLabel.setText(
            text: DateFormatter.localizedString(
                from: item.createdAt,
                dateStyle: .short,
                timeStyle: .none
            )
        )
        pageLabel.setText(text: "\(item.page)p")
    }
}

private extension BookDetailViewCell {
    func setupViews() {
        contentView.addSubviews(noteLabel, lowerStack)
        [emotionStack, pageLabel].forEach(lowerStack.addArrangedSubview)
        [emotionLabel, creationLabel].forEach(emotionLabelStack.addArrangedSubview)
        [emotionIcon, emotionLabelStack].forEach(emotionStack.addArrangedSubview)
    }
    
    func configure() {
        noteLabel.numberOfLines = Constants.noteMaxNumberOfLines
        noteLabel.lineBreakMode = .byTruncatingTail
        backgroundColor = .bkBaseColor(.secondary)
        layer.cornerRadius = LayoutConstants.cornerRadius
        clipsToBounds = true
    }
    
    func setupLayout() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width - LayoutConstants.horizontalInset * 2)
        }
        
        noteLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(LayoutConstants.topInset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        emotionIcon.snp.makeConstraints {
            $0.size.equalTo(LayoutConstants.imageSize)
        }
        
        lowerStack.snp.makeConstraints {
            $0.top.equalTo(noteLabel.snp.bottom)
                .offset(LayoutConstants.contentSpacing)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalToSuperview()
                .inset(LayoutConstants.bottomInset)
        }
    }
}

private extension BookDetailViewCell {
    enum LayoutConstants {
        static let emotionStackSpacing = BKSpacing.spacing2
        static let horizontalInset = BKInset.inset5
        static let contentSpacing = BKSpacing.spacing4
        static let topInset = BKInset.inset5
        static let bottomInset = BKInset.inset4
        static let cornerRadius = BKRadius.medium
        static let imageSize: CGSize = CGSize(width: 40, height: 40)
        static let imageCornerRadius: CGFloat = 20
    }
    
    enum Constants {
        static let noteMaxNumberOfLines: Int = 4
    }
}

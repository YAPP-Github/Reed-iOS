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
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let emotionIcon = UIImageView()
    private let emotionLabel = BKLabel2(
        fontStyle: .body1(weight: .semiBold),
        color: .bkContentColor(.brand)
    )
    
    private let creationLabel = BKLabel2(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.tertiary)
    )
    
    private let pageLabel = BKLabel2(
        fontStyle: .italic,
        color: .bkContentColor(.tertiary)
    )
    
    private let moreButton: UIImageView = {
        let imageView = UIImageView(
            image: BKImage.Icon.moreVertical
                .withRenderingMode(.alwaysTemplate)
        )
        imageView.tintColor = .bkContentColor(.tertiary)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private var moreButtonAction: (() -> Void)?
    
    private let upperStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
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
        let emotion = item.emotion ?? .joy
        
        let displayedNote = "\"\(item.note)\""
        noteLabel.setText(text: displayedNote)
        emotionIcon.image = emotion.image
        emotionIcon.contentMode = .scaleAspectFill
        emotionIcon.layer.cornerRadius = LayoutConstants.imageCornerRadius
        emotionIcon.clipsToBounds = true
        emotionIcon.backgroundColor = .bkBaseColor(.primary)
        emotionLabel.setText(text: "#\(emotion.rawValue)")
        creationLabel.setText(text: item.createdAt.toKoreanDotDateString())
        pageLabel.setText(text: "\(item.page)p")
    }
    
    func applyMoreButtonGesture(
        action: @escaping () -> Void
    ) {
        moreButtonAction = action
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleMoreButtonTapped)
        )
        moreButton.addGestureRecognizer(tap)
    }
}

private extension BookDetailViewCell {
    func setupViews() {
        contentView.addSubviews(upperStack, noteLabel, lowerStack)
        [emotionStack, moreButton].forEach(upperStack.addArrangedSubview)
        [creationLabel, pageLabel].forEach(lowerStack.addArrangedSubview)
        [emotionIcon, emotionLabel].forEach(emotionStack.addArrangedSubview)
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
        
        upperStack.snp.makeConstraints {
            $0.top.equalToSuperview()
                .inset(LayoutConstants.topInset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        noteLabel.snp.makeConstraints {
            $0.top.equalTo(upperStack.snp.bottom)
                .offset(LayoutConstants.noteLabelTopInset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        lowerStack.snp.makeConstraints {
            $0.top.equalTo(noteLabel.snp.bottom)
                .offset(LayoutConstants.lowerLabelTopInset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalToSuperview()
                .inset(LayoutConstants.bottomInset)
        }
        
        moreButton.snp.makeConstraints {
            $0.size.equalTo(LayoutConstants.moreButtonSize)
        }
        
        emotionIcon.snp.makeConstraints {
            $0.size.equalTo(LayoutConstants.emotionImageSize)
        }
    }
    
    @objc func handleMoreButtonTapped() {
        moreButtonAction?()
    }
}

private extension BookDetailViewCell {
    enum LayoutConstants {
        static let emotionStackSpacing = BKSpacing.spacing2
        static let noteLabelTopInset = BKInset.inset3
        static let lowerLabelTopInset = BKInset.inset2
        static let horizontalInset = BKInset.inset5
        static let contentSpacing = BKSpacing.spacing4
        static let topInset = BKInset.inset5
        static let bottomInset = BKInset.inset4
        static let cornerRadius = BKRadius.medium
        static let emotionImageSize: CGSize = CGSize(width: 32, height: 32)
        static let moreButtonSize: CGSize = CGSize(width: 20, height: 20)
        static let imageCornerRadius: CGFloat = 20
    }
    
    enum Constants {
        static let noteMaxNumberOfLines: Int = 4
    }
}

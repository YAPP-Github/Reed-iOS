// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKCore
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

    private let pageLabel = BKLabel2(
        fontStyle: .italic,
        color: .bkContentColor(.brand)
    )

    private let creationLabel = BKLabel2(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.tertiary)
    )

    private let emotionTagLabel = BKLabel2(
        fontStyle: .label1(weight: .medium),
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
        pageLabel.setText(text: "")
        creationLabel.setText(text: "")
        emotionTagLabel.setText(text: "")
    }

    func configure(
        with item: BookDetailItem
    ) {
        let emotion = item.primaryEmotion

        let displayedNote = "\"\(item.note)\""
        noteLabel.setText(text: displayedNote)
        emotionTagLabel.setText(text: "#\(emotion.displayName)")
        creationLabel.setText(text: item.createdAt.toKoreanDotDateString())
        pageLabel.setText(text: item.page.toPageString)
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
        [pageLabel, moreButton].forEach(upperStack.addArrangedSubview)
        [emotionTagLabel, creationLabel].forEach(lowerStack.addArrangedSubview)
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
            $0.height.equalTo(LayoutConstants.lowerLabelHeight)
            $0.bottom.equalToSuperview()
                .inset(LayoutConstants.bottomInset)
        }

        moreButton.snp.makeConstraints {
            $0.size.equalTo(LayoutConstants.moreButtonSize)
        }
    }

    @objc func handleMoreButtonTapped() {
        moreButtonAction?()
    }
}

private extension BookDetailViewCell {
    enum LayoutConstants {
        static let noteLabelTopInset = BKInset.inset4
        static let lowerLabelTopInset = BKInset.inset3
        static let horizontalInset = BKInset.inset5
        static let topInset = BKInset.inset5
        static let bottomInset = BKInset.inset4
        static let cornerRadius = BKRadius.medium
        static let lowerLabelHeight = 22
        static let moreButtonSize: CGSize = CGSize(width: 20, height: 20)
    }

    enum Constants {
        static let noteMaxNumberOfLines: Int = 4
    }
}

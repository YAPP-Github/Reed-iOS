// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

final class SentenceCardView: BaseView {
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    
    private lazy var emotionBackgroundImageView = UIImageView()
    private lazy var sentenceLabel = BKLabel(
        fontStyle: .body3(weight: .stMedium),
        color: .bkContentColor(.primary),
        alignment: .left
    )
    private lazy var titleLabel = BKLabel(
        fontStyle: .caption3(weight: .stMedium),
        color: .bkContentColor(.primary),
        alignment: .right
    )
    
    private let guideLabel = BKLabel(
        text: "인상 깊은 문장을\n공유해보세요!",
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.secondary),
        alignment: .center
    )
    
    private let saveButton: BKButton = BKButton(
        style: .secondary,
        size: .large
    )
    private let shareButton: BKButton = BKButton(size: .large)
    private lazy var bottomButtons = BKButtonGroup(buttons: [saveButton, shareButton])
    
    let eventPublisher = PassthroughSubject<SentenceCardViewEvent, Never>()
    
    override func setupView() {
        backgroundColor = .bkBaseColor(.primary)
        
        sentenceLabel.numberOfLines = 7
        titleLabel.numberOfLines = 1
        sentenceLabel.lineBreakMode = .byTruncatingTail
        titleLabel.lineBreakMode = .byTruncatingMiddle
        
        emotionBackgroundImageView.clipsToBounds = true
        emotionBackgroundImageView.layer.masksToBounds = true
        emotionBackgroundImageView.layer.cornerRadius = BKRadius.medium
        emotionBackgroundImageView.contentMode = .scaleAspectFill
        emotionBackgroundImageView.backgroundColor = .clear
        
        saveButton.leftIcon = BKImage.Icon.download
        saveButton.title = "이미지 저장"
        shareButton.leftIcon = BKImage.Icon.share2
        shareButton.title = "카드 공유"
        
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        
        guideLabel.numberOfLines = 2
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        emotionBackgroundImageView.addSubviews(sentenceLabel, titleLabel)
        contentView.addSubviews(emotionBackgroundImageView, guideLabel)
        
        scrollView.addSubview(contentView)
        addSubviews(scrollView, bottomButtons)
    }
    
    override func setupLayout() {
        sentenceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(64)
            $0.directionalHorizontalEdges.equalToSuperview().inset(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(sentenceLabel.snp.bottom).offset(24)
            $0.directionalHorizontalEdges.equalToSuperview().inset(32)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalTo(bottomButtons.snp.top)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        emotionBackgroundImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.directionalHorizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(emotionBackgroundImageView.snp.width).multipliedBy(468.0 / 335.0)
        }
        
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(emotionBackgroundImageView.snp.bottom).offset(32)
            $0.directionalHorizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24)
        }
        
        bottomButtons.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            $0.directionalHorizontalEdges.equalToSuperview()
        }
    }
    
    public func configure(_ data: BookDetailItem) {
        sentenceLabel.setText(text: data.note)
        titleLabel.setText(text: data.bookTitle.withCornerBrackets())
        if data.primaryEmotion != .other {
            emotionBackgroundImageView.image = data.primaryEmotion.cardImage
        } else {
            emotionBackgroundImageView.backgroundColor = .bkBaseColor(.secondary)
        }
    }
    
    public func renderCardImageWithoutCornerRadius() -> UIImage {
        let targetView = self.emotionBackgroundImageView
        let originalCornerRadius = targetView.layer.cornerRadius
        defer {
            targetView.layer.cornerRadius = originalCornerRadius
        }
        targetView.layer.cornerRadius = 0
        
        return targetView.asImage()
    }
}

private extension SentenceCardView {
    @objc func didTapSaveButton() {
        eventPublisher.send(.didTapSaveButton)
    }
    
    @objc func didTapShareButton() {
        eventPublisher.send(.didTapShareButton)
    }
}

extension String {
    /// 문자열 앞뒤에 『 』 괄호를 추가하여 새로운 문자열을 반환합니다.
    func withCornerBrackets() -> String {
        return "『\(self)』"
    }
}

extension UIView {
    /// 현재 뷰의 내용을 기반으로 UIImage를 생성합니다.
    func asImage(scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = max(scale, 3.0)
        format.opaque = false
        format.preferredRange = .standard
        
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds, format: format)
        
        return renderer.image { context in
            context.cgContext.interpolationQuality = .high
            context.cgContext.setShouldAntialias(true)
            context.cgContext.setAllowsAntialiasing(true)
            context.cgContext.setShouldSmoothFonts(true)
            context.cgContext.setFillColor(UIColor.clear.cgColor)
            context.cgContext.fill(self.bounds)

            layer.render(in: context.cgContext)
        }
    }
}

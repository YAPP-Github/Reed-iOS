// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import SnapKit
import UIKit

final class SentenceCardView: BaseView {
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
    
    override func setupView() {
        backgroundColor = .bkBaseColor(.primary)
        
        sentenceLabel.numberOfLines = 7
        titleLabel.numberOfLines = 1
        sentenceLabel.lineBreakMode = .byTruncatingTail
        titleLabel.lineBreakMode = .byTruncatingTail
        
        emotionBackgroundImageView.clipsToBounds = true
        emotionBackgroundImageView.layer.cornerRadius = BKRadius.medium
        emotionBackgroundImageView.contentMode = .scaleAspectFill
        emotionBackgroundImageView.backgroundColor = .clear
        
        saveButton.leftIcon = BKImage.Icon.download
        saveButton.title = "이미지 저장"
        shareButton.leftIcon = BKImage.Icon.share2
        shareButton.title = "카드 공유"
        
        guideLabel.numberOfLines = 2
        
        emotionBackgroundImageView.addSubviews(sentenceLabel, titleLabel)
        addSubviews(emotionBackgroundImageView, guideLabel, bottomButtons)
    }
    
    override func layoutSubviews() {
        sentenceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(64)
            $0.directionalHorizontalEdges.equalToSuperview().inset(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(sentenceLabel.snp.bottom).offset(24)
            $0.directionalHorizontalEdges.equalToSuperview().inset(32)
        }
        
        emotionBackgroundImageView.snp.makeConstraints {
            $0.top.directionalHorizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(468)
        }
        
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(emotionBackgroundImageView.snp.bottom).offset(32)
            $0.directionalHorizontalEdges.equalToSuperview().inset(20)
        }
        
        bottomButtons.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            $0.directionalHorizontalEdges.equalToSuperview()
        }
    }
    
    public func configure(_ data: BookDetailItem) {
        sentenceLabel.setText(text: data.note)
        titleLabel.setText(text: data.bookTitle.withCornerBrackets())
        if let emotion = data.emotion {
            emotionBackgroundImageView.image = emotion.cardImage
        } else {
            emotionBackgroundImageView.backgroundColor = .bkBaseColor(.secondary)
        }
    }
}

extension String {
    /// 문자열 앞뒤에 『 』 괄호를 추가하여 새로운 문자열을 반환합니다.
    func withCornerBrackets() -> String {
        return "『\(self)』"
    }
}

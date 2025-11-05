// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import SnapKit
import UIKit

enum EmotionIcon: String {
    case warmth = "#따뜻함"
    case joy = "#즐거움"
    case sadness = "#슬픔"
    case insight = "#깨달음"
    
    var icon: UIImage {
        switch self {
        case .warmth: return BKImage.Graphics.warmCircle
        case .joy: return BKImage.Graphics.joyCircle
        case .sadness: return BKImage.Graphics.sadCircle
        case .insight: return BKImage.Graphics.insightCircle
        }
    }
    
    static func from(emotion: Emotion) -> Self {
        switch emotion {
        case .warmth:
            return .warmth
        case .joy:
            return .joy
        case .sad:
            return .sadness
        case .insight:
            return .insight
        }
    }
}

final class AppreciationResultView: BaseView {
    private let containerView = UIView()
    
    private let titleLabel = BKLabel(
        text: "감상평 기록",
        fontStyle: .body1(weight: .medium),
        color: .bkContentColor(.primary)
    )
    
    private let rootStackBackgroundView = UIView()
    private let rootStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.rootStackSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private let emotionIcon = UIImageView()
    private let emotionLabel = BKLabel(
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
    
    private let creationLabel = BKLabel(
        fontStyle: .label2(weight: .regular),
        color: .bkContentColor(.tertiary),
        alignment: .right
    )
    
    private let summaryStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let appreciationLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.secondary)
    )
    
    override func setupView() {
        addSubview(containerView)
        [emotionIcon, emotionLabel].forEach(emotionStack.addArrangedSubview(_:))
        [emotionStack, creationLabel].forEach(summaryStack.addArrangedSubview(_:))
        [summaryStack, appreciationLabel].forEach(rootStack.addArrangedSubview(_:))
        rootStackBackgroundView.addSubview(rootStack)
        containerView.addSubviews(titleLabel, rootStackBackgroundView)
    }
    
    override func configure() {
        appreciationLabel.numberOfLines = 0
        rootStackBackgroundView.backgroundColor = .bkBaseColor(.secondary)
        rootStackBackgroundView.layer.cornerRadius = LayoutConstants.rootStackRadius
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        rootStackBackgroundView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(LayoutConstants.rootStackTopOffset)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        rootStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
                .inset(LayoutConstants.rootStackInset)
        }
        
        appreciationLabel.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        
        summaryStack.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        
        emotionIcon.snp.makeConstraints {
            $0.size.equalTo(
                CGSize(
                    width: LayoutConstants.emotionIconSize,
                    height: LayoutConstants.emotionIconSize
                )
            )
        }
    }
    
    func apply(
        emotion: EmotionIcon,
        creationDate: Date,
        appreciation: String? = ""
    ) {
        emotionIcon.image = emotion.icon
        emotionLabel.setText(text: emotion.rawValue)
        creationLabel.setText(text: creationDate.toKoreanDateString())
        
        if let review = appreciation, !review.isEmpty {
                appreciationLabel.setText(text: review)
                appreciationLabel.isHidden = false
                rootStack.spacing = LayoutConstants.rootStackSpacing
            } else {
                appreciationLabel.isHidden = true
                rootStack.spacing = 0
            }
    }
}

private extension AppreciationResultView {
    enum LayoutConstants {
        static let rootStackSpacing = BKSpacing.spacing3
        static let rootStackTopOffset = BKInset.inset2
        static let rootStackInset = BKInset.inset4
        static let rootStackRadius = BKRadius.medium
        static let emotionStackSpacing = BKSpacing.spacing2
        static let emotionIconSize: CGFloat = 40
    }
}

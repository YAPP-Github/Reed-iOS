// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

struct EmotionRegistrationForm {
    let emotion: Emotion
}

enum Emotion {
    case someEmotion1
    case someEmotion2
    case someEmotion3
    case someEmotion4
    
    var emotionView: UIView {
        let tmpView = UIView()
        tmpView.snp.makeConstraints {
            $0.height.equalTo(210)
        }
        
        tmpView.backgroundColor = .bkContentColor(.tertiary)
        tmpView.layer.cornerRadius = 12
        
        switch self {
        case .someEmotion1:
            return tmpView
        case .someEmotion2:
            return tmpView
        case .someEmotion3:
            return tmpView
        case .someEmotion4:
            return tmpView
        }
    }
}

final class EmotionRegistrationView: BaseView {
    private let containerView = UIView()
    private let titleLabel = BKLabel(
        text: "문장에 대해 어떤 감정이 드셨나요?",
        fontStyle: .heading1(weight: .bold)
    )
    
    private let subtitleLabel = BKLabel(
        text: "대표 감정을 한 가지 선택해주세요",
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.tertiary)
    )
    
    private var selectedEmotion: Emotion?
    
    private let titleStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.titleStackSpacing
        return stackView
    }()
    
    private let emotionVStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.emotionStackSpacing
        return stackView
    }()
    
    override func setupView() {
        addSubview(containerView)
        containerView.addSubviews(titleStack, emotionVStack)
        [titleLabel, subtitleLabel].forEach(titleStack.addArrangedSubview(_:))
        makeEmotionHStack()
    }
    
    override func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        emotionVStack.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom)
                .offset(LayoutConstants.emotionVStackOffset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalToSuperview()
        }
    }
}

extension EmotionRegistrationView: RegistrationFormProvidable {
    func registrationForm() -> RegistrationForm? {
        guard let selectedEmotion else { return nil }
        return .emotion(.init(emotion: selectedEmotion))
    }
}

private extension EmotionRegistrationView {
    func makeEmotionHStack() {
        let firstStack = UIStackView()
        let secondStack = UIStackView()
        
        [firstStack, secondStack].forEach {
            $0.axis = .horizontal
            $0.spacing = LayoutConstants.emotionStackSpacing
            $0.distribution = .fillEqually
        }
        
        [Emotion.someEmotion1.emotionView, Emotion.someEmotion2.emotionView]
            .forEach(firstStack.addArrangedSubview(_:))
        
        [Emotion.someEmotion3.emotionView, Emotion.someEmotion4.emotionView]
            .forEach(secondStack.addArrangedSubview(_:))
        
        [firstStack, secondStack].forEach(emotionVStack.addArrangedSubview(_:))
    }
}

private extension EmotionRegistrationView {
    enum LayoutConstants {
        static let titleStackSpacing = BKSpacing.spacing1
        static let emotionStackSpacing = BKSpacing.spacing3
        static let horizontalInset = BKInset.inset5
        static let emotionVStackOffset: CGFloat = 40
    }
}

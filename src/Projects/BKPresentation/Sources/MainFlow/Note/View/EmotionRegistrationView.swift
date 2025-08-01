// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit

struct EmotionRegistrationForm {
    let emotion: Emotion
}

enum Emotion: String, CaseIterable {
    case someEmotion1 = "1"
    case someEmotion2 = "2"
    case someEmotion3 = "3"
    case someEmotion4 = "4"
    
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
    private let inputChangedSubject = PassthroughSubject<Void, Never>()
    
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
    
    private lazy var emotion1View = makeEmotionView(for: .someEmotion1)
    private lazy var emotion2View = makeEmotionView(for: .someEmotion2)
    private lazy var emotion3View = makeEmotionView(for: .someEmotion3)
    private lazy var emotion4View = makeEmotionView(for: .someEmotion4)
    
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

extension EmotionRegistrationView: RegistrationFormProvidable, FormInputNotifiable {
    var inputChangedPublisher: AnyPublisher<Void, Never> {
        inputChangedSubject.eraseToAnyPublisher()
    }

    private var emotionButtons: [Emotion: UIView] {
        [
            .someEmotion1: emotion1View,
            .someEmotion2: emotion2View,
            .someEmotion3: emotion3View,
            .someEmotion4: emotion4View
        ]
    }
    
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
        
        [emotion1View, emotion2View]
            .forEach(firstStack.addArrangedSubview(_:))
        
        [emotion3View, emotion4View]
            .forEach(secondStack.addArrangedSubview(_:))
        
        [firstStack, secondStack].forEach(emotionVStack.addArrangedSubview(_:))
    }
    
    func makeEmotionView(for emotion: Emotion) -> UIView {
        let view = emotion.emotionView
        view.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(emotionTapped(_:)))
        view.addGestureRecognizer(gesture)
        view.tag = emotion.hashValue
        return view
    }
    
    @objc func emotionTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view,
              let emotion = Emotion.allCases.first(where: { $0.hashValue == tappedView.tag }) else {
            return
        }

        selectedEmotion = emotion
        updateSelectionUI()
        inputChangedSubject.send(())
    }
    
    func updateSelectionUI() {
        emotionButtons.forEach { emotion, view in
            view.layer.borderWidth = (emotion == selectedEmotion)
                ? 2 : 0
            view.layer.borderColor = (emotion == selectedEmotion)
                ? UIColor.bkBorderColor(.brand).cgColor : nil
        }
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

// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import UIKit
import SnapKit

final class EmotionEditView: BaseView {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let emotionRegistrationView = EmotionRegistrationView()
    private let editButton = BKButton(style: .primary, size: .large)
    
    private let editButtonTappedSubject = PassthroughSubject<Void, Never>()
    var editButtonTappedPublisher: AnyPublisher<Void, Never> {
        editButtonTappedSubject.eraseToAnyPublisher()
    }
    
    private let getCurrentEmotionSubject = PassthroughSubject<Void, Never>()
    var getCurrentEmotionPublisher: AnyPublisher<Void, Never> {
        getCurrentEmotionSubject.eraseToAnyPublisher()
    }
    
    var selectedEmotion: Emotion? {
        guard let form = emotionRegistrationView.registrationForm(),
              case .emotion(let emotionForm) = form else { return nil }
        return emotionForm.emotion
    }
    
    override func setupView() {
        addSubviews(scrollView, editButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(emotionRegistrationView)
    }
    
    override func configure() {
        editButton.title = "수정하기"
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    override func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(editButton.snp.top).offset(-LayoutConstants.editButtonVerticalInset)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        emotionRegistrationView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(LayoutConstants.editButtonVerticalInset)
        }
        
        editButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.height.equalTo(52)
            $0.bottom.equalTo(safeAreaLayoutGuide)
                .inset(LayoutConstants.editButtonVerticalInset)
        }
    }
    
    func setSelectedEmotion(_ emotion: Emotion) {
        emotionRegistrationView.setSelectedEmotion(emotion)
    }
    
    func getCurrentSelectedEmotion() {
        getCurrentEmotionSubject.send(())
    }
    
    @objc private func editButtonTapped() {
        editButtonTappedSubject.send(())
    }
}

private extension EmotionEditView {
    enum LayoutConstants {
        static let editButtonVerticalInset = BKInset.inset5
        static let horizontalInset = BKInset.inset5
    }
}

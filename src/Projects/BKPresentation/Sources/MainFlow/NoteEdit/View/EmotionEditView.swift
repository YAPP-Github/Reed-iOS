// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import UIKit
import SnapKit

enum EmotionEditViewEvent {
    case editButtonTapped
    case emotionDidChange(PrimaryEmotion?)
    case emotionSelected(PrimaryEmotion)  // 감정 탭 시 (바텀시트 표시용)
}

final class EmotionEditView: BaseView {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let emotionRegistrationView = EmotionRegistrationView()
    private let editButton = BKButton(style: .primary, size: .large)
    
    let eventPublisher = PassthroughSubject<EmotionEditViewEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var currentSelectedPrimaryEmotion: PrimaryEmotion? {
        guard let form = emotionRegistrationView.registrationForm(),
              case .emotion(let emotionForm) = form else { return nil }
        return emotionForm.primaryEmotion
    }
    
    override func setupView() {
        addSubviews(scrollView, editButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(emotionRegistrationView)
    }
    
    override func configure() {
        editButton.title = "수정하기"
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)

        // 감정 탭 이벤트 전달 (바텀시트 표시용)
        emotionRegistrationView.onEmotionSelected = { [weak self] emotion in
            self?.eventPublisher.send(.emotionSelected(emotion))
        }

        emotionRegistrationView.inputChangedPublisher
            .sink { [weak self] _ in
                guard let self = self else { return }

                let newEmotion = self.currentSelectedPrimaryEmotion
                self.eventPublisher.send(.emotionDidChange(newEmotion))
            }
            .store(in: &cancellables)
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
    
    func setSelectedPrimaryEmotion(_ emotion: PrimaryEmotion) {
        emotionRegistrationView.setSelectedPrimaryEmotion(emotion)
    }

    @objc private func editButtonTapped() {
        eventPublisher.send(.editButtonTapped)
    }

    func setEditButtonEnabled(_ isEnabled: Bool) {
        editButton.isDisabled = !isEnabled
    }

    // MARK: - Detail Emotions

    func setDetailEmotions(_ detailEmotions: [DetailEmotion]) {
        emotionRegistrationView.setDetailEmotions(detailEmotions)
    }

    func getSelectedDetailEmotions() -> [DetailEmotion] {
        return emotionRegistrationView.getSelectedDetailEmotions()
    }

    func setLoadingEmotions(_ isLoading: Bool) {
        emotionRegistrationView.setLoadingEmotions(isLoading)
    }
}

private extension EmotionEditView {
    enum LayoutConstants {
        static let editButtonVerticalInset = BKInset.inset5
        static let horizontalInset = BKInset.inset5
    }
}

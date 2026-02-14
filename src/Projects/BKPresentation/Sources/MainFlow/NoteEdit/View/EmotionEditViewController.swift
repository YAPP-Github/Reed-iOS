// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import BKDomain
import Combine
import UIKit

final class EmotionEditViewController: BaseViewController<EmotionEditView> {
    override var bkNavigationTitle: String { "" }

    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .standard(viewController: self)
    }

    weak var coordinator: NoteEditCoordinator?
    private var cancellables = Set<AnyCancellable>()

    private let initialPrimaryEmotion: PrimaryEmotion?
    private let initialDetailEmotions: [DetailEmotion]
    @Published private var selectedPrimaryEmotion: PrimaryEmotion?
    private let completion: (PrimaryEmotion, [DetailEmotion]) -> Void

    @Autowired private var fetchDetailEmotionsUseCase: FetchDetailEmotionsUseCase

    // 바텀시트 표시 대기용
    private var pendingEmotionForSheet: PrimaryEmotion?
    private var isLoadingEmotions: Bool = false

    init(
        currentEmotion: PrimaryEmotion?,
        currentDetailEmotions: [DetailEmotion] = [],
        completion: @escaping (PrimaryEmotion, [DetailEmotion]) -> Void
    ) {
        self.initialPrimaryEmotion = currentEmotion
        self.initialDetailEmotions = currentDetailEmotions
        self.completion = completion
        self._selectedPrimaryEmotion = .init(initialValue: currentEmotion)
        super.init()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let emotion = initialPrimaryEmotion {
            contentView.setSelectedPrimaryEmotion(emotion)
            contentView.setDetailEmotions(initialDetailEmotions)
        }
        contentView.setEditButtonEnabled(false)
    }

    override func bindAction() {
        contentView.eventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .emotionDidChange(let newEmotion):
                    self.selectedPrimaryEmotion = newEmotion
                    self.updateEditButtonState()

                case .emotionSelected(let emotion):
                    // other가 아닌 경우 세부감정 바텀시트 표시
                    if emotion != .other {
                        self.fetchAndPresentDetailEmotionSheet(for: emotion)
                    }

                case .editButtonTapped:
                    if let emotion = self.selectedPrimaryEmotion {
                        let detailEmotions = self.contentView.getSelectedDetailEmotions()
                        self.completion(emotion, detailEmotions)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func updateEditButtonState() {
        let emotionChanged = selectedPrimaryEmotion != initialPrimaryEmotion
        let detailEmotionsChanged = contentView.getSelectedDetailEmotions() != initialDetailEmotions
        let isDiff = emotionChanged || detailEmotionsChanged
        contentView.setEditButtonEnabled(isDiff)
    }

    private func fetchAndPresentDetailEmotionSheet(for emotion: PrimaryEmotion) {
        guard !isLoadingEmotions else { return }

        isLoadingEmotions = true
        contentView.setLoadingEmotions(true)

        fetchDetailEmotionsUseCase.execute(for: emotion)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingEmotions = false
                    self?.contentView.setLoadingEmotions(false)
                    if case .failure = completion {
                        // 에러 처리 - 필요시 coordinator에서 처리
                    }
                },
                receiveValue: { [weak self] detailEmotions in
                    self?.presentDetailEmotionSheet(for: emotion, detailEmotions: detailEmotions)
                }
            )
            .store(in: &cancellables)
    }

    private func presentDetailEmotionSheet(for primaryEmotion: PrimaryEmotion, detailEmotions: [DetailEmotion]) {
        let currentDetailEmotions = contentView.getSelectedDetailEmotions()
        let sheet = BKBottomSheetViewController.makeDetailEmotionSheet(
            primaryEmotion: primaryEmotion,
            detailEmotions: detailEmotions,
            initialSelectedDetailEmotions: currentDetailEmotions,
            skipAction: { [weak self] in
                // 건너뛰기: 세부감정 초기화
                self?.contentView.setDetailEmotions([])
                self?.updateEditButtonState()
                self?.dismiss(animated: true)
            },
            confirmAction: { [weak self] selectedDetailEmotions in
                self?.contentView.setDetailEmotions(selectedDetailEmotions)
                self?.updateEditButtonState()
                self?.dismiss(animated: true)
            }
        )

        sheet.show(from: self, animated: true)
    }
}

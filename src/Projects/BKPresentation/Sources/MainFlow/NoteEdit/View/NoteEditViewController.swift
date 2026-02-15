// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import BKDomain
import Combine
import UIKit

final class NoteEditViewController: BaseViewController<NoteEditView>, ScreenLoggable {
    var screenName: String = GATracking.RecordFlow.edit

    override var bkNavigationTitle: String {
        return "독서 기록 수정"
    }
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .standard(
            viewController: self,
            rightButton: .init(
                target: self,
                action: #selector(handleMoreButtonTapped)
            )
        )
    }
    
    weak var coordinator: NoteEditCoordinator?
    let viewModel: AnyViewBindableViewModel<NoteEditViewModel.State, NoteEditViewModel.Action>
    private var cancellables = Set<AnyCancellable>()

    // 현재 상태 추적 (EmotionEditViewController에 전달용)
    private var currentPrimaryEmotion: PrimaryEmotion?
    private var currentDetailEmotions: [DetailEmotion] = []
    
    init(viewModel: NoteEditViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backButton = UIBarButtonItem(
            image: BKImage.Icon.x,
            style: .plain,
            target: self,
            action: #selector(customBackButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
        
        viewModel.send(.onAppear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logScreenView()
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0.recordInfo }
            .removeDuplicates()
            .sink { [weak self] recordInfo in
                self?.contentView.apply(recordInfo: recordInfo)
            }
            .store(in: &cancellables)
        
        viewModel.statePublisher
            .map { state -> (PrimaryEmotion?, [DetailEmotion]) in
                (state.selectedPrimaryEmotion, state.selectedDetailEmotions)
            }
            .removeDuplicates { (prev: (PrimaryEmotion?, [DetailEmotion]), curr: (PrimaryEmotion?, [DetailEmotion])) in
                prev.0 == curr.0 && prev.1 == curr.1
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotionTuple in
                self?.currentPrimaryEmotion = emotionTuple.0
                self?.currentDetailEmotions = emotionTuple.1
                self?.contentView.setEmotionInfo(
                    primaryEmotion: emotionTuple.0,
                    detailEmotions: emotionTuple.1
                )
            }
            .store(in: &cancellables)
        
        viewModel.statePublisher
            .map { $0.isLoading }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
            .store(in: &cancellables)
        
        viewModel.statePublisher
            .compactMap { $0.error }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.coordinator?.handleError(error)
                self?.viewModel.send(.errorHandled)
            }
            .store(in: &cancellables)
        
        viewModel.statePublisher
            .compactMap { $0.shouldPresentEmotionEdit }
            .removeDuplicates { $0.timestamp == $1.timestamp }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotionEditRequest in
                self?.handlePresentEmotionEdit(emotion: emotionEditRequest.emotion)
            }
            .store(in: &cancellables)
        
        viewModel.statePublisher
            .map { $0.saveCompleted }
            .removeDuplicates()
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.statePublisher
            .map { $0.deleteCompleted }
            .removeDuplicates()
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.statePublisher
            .map { $0.isDiff }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDiff in
                self?.contentView.setSaveButtonEnabled(isDiff)
            }
            .store(in: &cancellables)
    }
    
    override func bindAction() {
        contentView.eventPublisher
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .emotionStatusTapped:
                    self.presentEmotionEdit()
                case .saveButtonTapped:
                    self.handleSaveButtonTapped()
                case .pageDidChange(let text):
                    self.viewModel.send(.pageDidChange(text))
                case .sentenceDidChange(let text):
                    self.viewModel.send(.sentenceDidChange(text))
                case .memoDidChange(let text):
                    self.viewModel.send(.memoDidChange(text))
                }
            }
            .store(in: &cancellables)
    }
}

private extension NoteEditViewController {
    func presentEmotionEdit() {
        // 항상 감정 선택 화면으로 이동 (바텀시트는 EmotionEditViewController에서 처리)
        viewModel.send(.presentEmotionEdit)
    }

    func handlePresentEmotionEdit(emotion: PrimaryEmotion?) {
        coordinator?.didTapEmotionEdit(
            currentEmotion: emotion,
            currentDetailEmotions: currentDetailEmotions
        ) { [weak self] selectedEmotion, selectedDetailEmotions in
            self?.handleEmotionEditCompleted(emotion: selectedEmotion, detailEmotions: selectedDetailEmotions)
        }
    }

    func handleEmotionEditCompleted(emotion: PrimaryEmotion, detailEmotions: [DetailEmotion]) {
        viewModel.send(.emotionSelected(emotion))
        viewModel.send(.detailEmotionsSelected(detailEmotions))
    }
    
    func handleSaveButtonTapped() {
        viewModel.send(.saveButtonTapped)
    }
    
    func presentBookMoreMenu() {
        let sheet = BKBottomSheetViewController.makeDeleteOnlyMenuSheet(
            onDelete: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.handleDeleteButtonTapped()
                }
            }
        )
        
        sheet.show(from: self, animated: true)
    }
    
    func presentDeletionConfirmDialog() {
        let dialog = BKDialog(
            title: """
            삭제하면 기록을 복구할 수 없어요.
            정말 삭제하시겠어요?
            """,
            config: .init(
                leftButtonTitle: "취소",
                leftButtonAction: { [weak self] in
                    guard let self else { return }
                    self.dismiss(animated: true)
                },
                rightButtonTitle: "삭제",
                rightButtonAction: { [weak self] in
                    guard let self else { return }
                    self.dismiss(animated: true) {
                        self.viewModel.send(.deleteButtonTapped)
                    }
                }
            )
        )
        let dialogViewController = BKDialogViewController(dialog: dialog)
        present(dialogViewController, animated: true)
    }
    
    func handleDeleteButtonTapped() {
        presentDeletionConfirmDialog()
    }
    
    @objc func handleMoreButtonTapped() {
        presentBookMoreMenu()
    }
    
    @objc func customBackButtonTapped() {
        dismiss(animated: true)
    }
}

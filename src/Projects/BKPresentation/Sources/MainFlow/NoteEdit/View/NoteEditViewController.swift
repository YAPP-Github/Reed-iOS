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
            .map { $0.selectedEmotion }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotion in
                self?.contentView.setInitialEmotion(emotion)
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
        
    }
    
    override func bindAction() {
        contentView.eventPublisher
            .sink { [weak self] event in
                switch event {
                case .emotionStatusTapped:
                    self?.presentEmotionEdit()
                case .saveButtonTapped:
                    self?.handleSaveButtonTapped()
                }
            }
            .store(in: &cancellables)
    }
}

private extension NoteEditViewController {
    func presentEmotionEdit() {
        viewModel.send(.presentEmotionEdit)
    }
    
    func handlePresentEmotionEdit(emotion: Emotion?) {
        coordinator?.didTapEmotionEdit(currentEmotion: emotion) { [weak self] selectedEmotion in
            self?.handleEmotionSelected(selectedEmotion)
        }
    }
    
    func handleEmotionSelected(_ emotion: Emotion) {
        viewModel.send(.emotionSelected(emotion))
    }
    
    func handleSaveButtonTapped() {
        let formData = contentView.getCurrentFormData()
        viewModel.send(.saveButtonTapped(formData: formData))
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

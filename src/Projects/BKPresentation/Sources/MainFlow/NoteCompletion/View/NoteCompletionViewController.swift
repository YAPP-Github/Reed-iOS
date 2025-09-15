// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import Combine
import UIKit

final class NoteCompletionViewController: BaseViewController<NoteCompletionView>, ScreenLoggable {
    var screenName: String = GATracking.RecordFlow.detail

    override var bkNavigationTitle: String {
        return "독서 기록"
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
    
    weak var coordinator: NoteCompletionCoordinator?
    private var cancellable: Set<AnyCancellable> = []
    private let viewModel: AnyViewBindableViewModel<NoteCompletionViewModel.State, NoteCompletionViewModel.Action>
    private let recordId: String
    
    init(viewModel: NoteCompletionViewModel, recordId: String) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        self.recordId = recordId
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        let backButton = UIBarButtonItem(
            image: BKImage.Icon.x,
            style: .plain,
            target: self,
            action: #selector(customBackButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
        
        viewModel.send(.onAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logScreenView()
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0.recordInfo }
            .sink { [weak self] recordInfo in
                self?.contentView.apply(recordInfo: recordInfo)
            }
            .store(in: &cancellable)
        
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
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0.error }
            .sink { [weak self] _ in
                self?.presentErrorDialog()
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map { $0.deleteCompleted }
            .removeDuplicates()
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .filter { $0.shareTriggered }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let recordInfo = state.recordInfo else { return }
                let item = BookDetailItem.from(recordInfo: recordInfo)
                if let self = self {
                    self.coordinator?.goToShareView(item: item)
                }
                self?.viewModel.send(.shareHandled)
            }
            .store(in: &cancellable)
    }
    
    func presentNoteMoreMenu() {
        let sheet = BKBottomSheetViewController.makeMoreMenuSheet(
            onShare: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.handleNoteShareButtonTapped()
                }
            },
            onEdit: { [weak self] in
                self?.dismiss(animated: true) { [weak self] in
                    self?.handleNoteEditButtonTapped()
                }
            },
            onDelete: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.handleNoteDeleteButtonTapped()
                }
            }
        )
        
        sheet.show(from: self, animated: true)
    }
    
    func handleNoteShareButtonTapped() {
        viewModel.send(.shareButtonTapped)
    }
    
    func handleNoteEditButtonTapped() {
        coordinator?.didTapEditButton(recordId: recordId)
    }
    
    func handleNoteDeleteButtonTapped() {
        presentDeletionConfirmDialog()
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
    
    func presentErrorDialog() {
        let dialog = BKDialog(
            title: "오류",
            config: .init(
                leftButtonTitle: "기록을 불러올 수 없습니다.",
                leftButtonAction: { [weak self] in
                    self?.dismiss(animated: true) { [weak self] in
                        self?.viewModel.send(.errorHandled)
                    }
                }
            )
        )
        let dialogViewController = BKDialogViewController(dialog: dialog)
        self.present(dialogViewController, animated: true)
    }
    
    @objc private func customBackButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc func handleMoreButtonTapped() {
        presentNoteMoreMenu()
    }
}

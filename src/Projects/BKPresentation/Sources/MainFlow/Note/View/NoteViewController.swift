// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import UIKit

enum NoteViewEvent: Equatable {
    case completeForm(NoteForm)
    case didTapGuideButton
    case didTapOCRButton
    case setScannedText(String)
}

final class NoteViewController: BaseViewController<NoteView> {
    weak var coordinator: NoteCoordinator?
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        return .standard(viewController: self)
    }
    
    override var bkNavigationTitle: String { "" }
    
    private var cancellable: Set<AnyCancellable> = []
    private let viewModel: AnyViewBindableViewModel<NoteViewModel.State, NoteViewModel.Action>
    
    init(viewModel: NoteViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        
        let backButton = UIBarButtonItem(
            image: BKImage.Icon.chevronLeft,
            style: .plain,
            target: self,
            action: #selector(customBackButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func bindAction() {
        contentView.eventPublisher
            .compactMap { event -> NoteForm? in
                if case let .completeForm(form) = event { return form }
                return nil
            }
            .sink { [weak self] form in
                self?.viewModel.send(.submitNoteForm(form))
            }
            .store(in: &cancellable)
        
        contentView.eventPublisher
            .filter { $0 == .didTapGuideButton }
            .sink { [weak self] _ in
                self?.presentAppreciationGuide()
            }
            .store(in: &cancellable)
        
        contentView.eventPublisher
            .filter { $0 == .didTapOCRButton }
            .sink { [weak self] _ in
                self?.coordinator?.showOCRScanner()
            }
            .store(in: &cancellable)
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .map { $0.selectedGuideText }
            .sink { [weak self] selectedText in
                self?.contentView.setAppreciationText(selectedText)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { $0.shouldStartEditing }
            .filter { $0 }
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.contentView.startEditingIfNeeded() 
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates { $0.createCompleted == $1.createCompleted }
            .filter { $0.createCompleted }
            .compactMap(\.recordInfo)
            .sink { [weak self] in
                self?.presentRegistrationSuccessDialog(recordInfo: $0)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map(\.error)
            .removeDuplicates()
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.coordinator?.handleError(error)
                self?.viewModel.send(.errorHandled)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map(\.isRetrying)
            .removeDuplicates()
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.coordinator?.presentCustomErrorAlert(
                    subtitle: """
                    일시적인 오류로 
                    데이터를 불러올 수 없어요
                    """,
                    onConfirm: { [weak self] in
                        self?.viewModel.send(.retryTapped)
                    }
                )
                self?.viewModel.send(.errorHandled)
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
    }
}

extension NoteViewController {
    func setScannedText(_ text: String) {
        contentView.handleEvent(.setScannedText(text))
    }
}

private extension NoteViewController {
    @objc func customBackButtonTapped() {
        let currentPage = contentView.pageControl.currentPage
        if currentPage == 0 {
            presentCancelConfirmationDialog()
        } else {
            contentView.pageControl.currentPage -= 1
        }
    }
    
    func presentRegistrationSuccessDialog(recordInfo: RecordInfo) {
        let imageView = UIImageView(image: BKImage.Graphics.noteCompleted)
        
        let dialog = BKDialog(
            title: "기록이 저장되었어요!",
            subtitle: "방금 남긴 기록을 확인해볼까요?",
            config: .init(
                leftButtonTitle: "닫기",
                leftButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                    self?.navigationController?.popViewController(animated: true)
                },
                rightButtonTitle: "기록 보러가기",
                rightButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                    self?.coordinator?.didCompleteNoteCreation(recordInfo: recordInfo)
                }
            ),
            suppliedContentStyle: .upper(imageView)
        )
        
        let dialogViewController = BKDialogViewController(dialog: dialog)
        present(dialogViewController, animated: true)
    }
    
    func presentCancelConfirmationDialog() {
        let dialog = BKDialog(
            title: "기록을 그만하고 나가시겠어요?",
            subtitle: "지금까지 기록한 내용은 저장되지 않습니다.",
            config: .init(
                leftButtonTitle: "취소",
                leftButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                },
                rightButtonTitle: "확인",
                rightButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                    self?.coordinator?.popAndFinish()
                }
            )
        )
        
        let dialogViewController = BKDialogViewController(dialog: dialog)
        present(dialogViewController, animated: true)
    }
    
    func presentAppreciationGuide() {
        let sheet = BKBottomSheetViewController.makeAppreciationGuideSheet(
            confirmAction: { [weak self] selectedGuide in
                self?.viewModel.send(.appreciationGuideSelected(selectedGuide.rawValue))
                self?.dismiss(animated: true)
            }
        )
        
        sheet.show(from: self, animated: true)
    }
}

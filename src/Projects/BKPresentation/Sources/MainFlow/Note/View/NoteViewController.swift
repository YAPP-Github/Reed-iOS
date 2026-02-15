// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import BKDomain
import Combine
import UIKit

enum NoteViewEvent: Equatable {
    case completeForm(NoteForm)
    case didTapOCRButton
    case setScannedText(String)
    case didSelectEmotion(PrimaryEmotion)
}

final class NoteViewController: BaseViewController<NoteView>, ScreenLoggable {
    var screenName: String = GATracking.RecordFlow.start
    weak var coordinator: NoteCoordinator?

    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        return .standard(viewController: self)
    }

    override var bkNavigationTitle: String { "" }

    private var cancellable: Set<AnyCancellable> = []
    private let viewModel: AnyViewBindableViewModel<NoteViewModel.State, NoteViewModel.Action>
    private var pendingEmotionForSheet: PrimaryEmotion?

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
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
            .filter { $0 == .didTapOCRButton }
            .sink { [weak self] _ in
                self?.coordinator?.showOCRScanner()
            }
            .store(in: &cancellable)

        contentView.eventPublisher
            .compactMap { event -> PrimaryEmotion? in
                if case let .didSelectEmotion(emotion) = event { return emotion }
                return nil
            }
            .sink { [weak self] emotion in
                self?.pendingEmotionForSheet = emotion
                self?.viewModel.send(.fetchDetailEmotions(emotion))
            }
            .store(in: &cancellable)

        // TODO: - Remove KVO Binding
        contentView.pageControl.publisher(for: \.currentPage)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentPage in
                self?.logPageView(for: currentPage)
            }
            .store(in: &cancellable)
    }

    override func bindState() {
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
            .compactMap { $0 }
            .removeDuplicates()
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

        // Sync isLoadingEmotions state to view
        viewModel.statePublisher
            .map(\.isLoadingEmotions)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.contentView.setLoadingEmotions(isLoading)
            }
            .store(in: &cancellable)

        // Detail emotions loaded - present bottom sheet
        // Watch for isLoadingEmotions transition from true to false (loading completed)
        viewModel.statePublisher
            .map { ($0.isLoadingEmotions, $0.detailEmotions) }
            .scan((false, false, [DetailEmotion]())) { prev, current in
                // (wasLoading, isLoading, detailEmotions)
                (prev.1, current.0, current.1)
            }
            .filter { wasLoading, isLoading, _ in wasLoading && !isLoading }
            .map { $0.2 }
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detailEmotions in
                guard let self,
                      let primaryEmotion = self.pendingEmotionForSheet else { return }
                self.presentDetailEmotionSheet(for: primaryEmotion, detailEmotions: detailEmotions)
                self.pendingEmotionForSheet = nil
            }
            .store(in: &cancellable)
    }
}

extension NoteViewController {
    func setScannedText(_ text: String) {
        contentView.handleEvent(.setScannedText(text))
    }

    private func logPageView(for pageIndex: Int) {
        switch pageIndex {
        case 0: // sentence 페이지
            logScreenView(name: GATracking.RecordFlow.inputSentence)
        case 1: // emotion 페이지
            logScreenView(name: GATracking.RecordFlow.selectEmotion)
        default:
            break
        }
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
        logScreenView(name: GATracking.RecordFlow.complete)

        let imageView = UIImageView(image: BKImage.Graphics.noteCompleted)
        let dialog = BKDialog(
            title: "기록이 저장되었어요!",
            subtitle: "방금 남긴 기록을 확인해볼까요?",
            config: .init(
                leftButtonTitle: "닫기",
                leftButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                    self?.coordinator?.popAndFinish()
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

    func presentDetailEmotionSheet(for primaryEmotion: PrimaryEmotion, detailEmotions: [DetailEmotion]) {
        let currentDetailEmotions = contentView.getSelectedDetailEmotions()
        let sheet = BKBottomSheetViewController.makeDetailEmotionSheet(
            primaryEmotion: primaryEmotion,
            detailEmotions: detailEmotions,
            initialSelectedDetailEmotions: currentDetailEmotions,
            skipAction: { [weak self] in
                // 건너뛰기: 세부감정 없이 진행
                self?.contentView.setDetailEmotions([])
                self?.dismiss(animated: true)
            },
            confirmAction: { [weak self] selectedDetailEmotions in
                self?.contentView.setDetailEmotions(selectedDetailEmotions)
                self?.dismiss(animated: true)
            }
        )

        sheet.show(from: self, animated: true)
    }
}

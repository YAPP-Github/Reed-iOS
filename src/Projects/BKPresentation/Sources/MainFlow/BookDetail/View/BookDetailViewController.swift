// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import BKDomain
import Combine
import UIKit

enum BookDetailViewEvent: Equatable {
    case didTapStatusButton
    case didTapAddNoteButton
    case didTapSortMenuButton(SortOption?)
    case didTapCell(recordId: String)
    case didTapMoreButton(recordId: String)
    case didReachBottom
}

final class BookDetailViewController: BaseViewController<BookDetailView>, ScreenLoggable {
    var screenName: String = GATracking.HomeAndLibrary.bookDetail

    override var bkNavigationTitle: String { "" }
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .standard(
            viewController: self,
            rightButton: .init(
                target: self,
                action: #selector(handleMoreButtonTapped)
            )
        )
    }
    
    weak var coordinator: BookDetailCoordinator?
    
    private var cancellable = Set<AnyCancellable>()
    let viewModel: AnyViewBindableViewModel<BookDetailViewModel.State, BookDetailViewModel.Action>
    
    init(viewModel: BookDetailViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
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
    
    override func bindAction() {
        contentView.eventPublisher
            .filter { $0 == .didTapStatusButton }
            .sink { [weak self] _ in
                self?.viewModel.send(.statusButtonTapped)
            }
            .store(in: &cancellable)
        
        contentView.eventPublisher
            .filter { $0 == .didTapAddNoteButton }
            .sink { [weak self] _ in
                self?.viewModel.send(.addNoteButtonTapped)
            }
            .store(in: &cancellable)
        
        contentView.eventPublisher
            .compactMap { event -> SortOption? in
                if case let .didTapSortMenuButton(option) = event { return option }
                return nil
            }
            .sink { [weak self] option in
                self?.presentBookDetailSortMenu(option)
            }
            .store(in: &cancellable)
        
        contentView.eventPublisher
            .compactMap { event -> String? in
                if case let .didTapCell(recordId) = event { return recordId }
                return nil
            }
            .sink { [weak self] recordId in
                self?.viewModel.send(.cellTapped(recordId: recordId))
            }
            .store(in: &cancellable)
        
        contentView.eventPublisher
            .compactMap { event -> String? in
                if case let .didTapMoreButton(recordId) = event { return recordId }
                return nil
            }
            .sink { [weak self] recordId in
                self?.presentNoteMoreMenu(recordId: recordId)
            }
            .store(in: &cancellable)
        
        contentView.eventPublisher
            .filter { $0 == .didReachBottom }
            .throttle(for: .milliseconds(800), scheduler: RunLoop.main, latest: false)
            .sink { [weak self] _ in
                self?.viewModel.send(.loadNextPage)
            }
            .store(in: &cancellable)
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { state in
                ItemsAndTotal(
                    itemIDs: state.items.map(\.recordId),
                    items: state.items,
                    total: state.totalResults
                )
            }
            .removeDuplicates()
            .sink { [weak self] output in
                self?.contentView.applySnapshot(with: output.items, totalCount: output.total)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0.currentBook }
            .removeDuplicates()
            .sink { [weak self] in
                self?.contentView.configureInnerView(book: $0)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0.sortOption }
            .removeDuplicates()
            .sink { [weak self] in
                self?.contentView.applySort(option: $0)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .filter { $0.isAddNoteTriggered }
            .sink { [weak self] in
                self?.coordinator?.didTapAddNoteButton(bookId: $0.userBookId)
                self?.viewModel.send(.addNoteHandled)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .filter { $0.isStatusButtonTriggered }
            .sink { [weak self] in
                self?.presentBookRegistration($0.currentBook)
                self?.viewModel.send(.changeStatusHandled)
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
            .receive(on: DispatchQueue.main)
            .filter { $0.isCellTapped }
            .sink { [weak self] state in
                guard let recordId = state.selectedRecordId else { return }
                self?.coordinator?.didTapCell(recordId: recordId)
                self?.viewModel.send(.cellTapHandled)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map(\.seeds)
            .removeDuplicates()
            .sink { [weak self] in
                self?.contentView.applySeedReport(with: $0)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map { $0.deleteCompleted }
            .removeDuplicates()
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.logScreenView(name: GATracking.HomeAndLibrary.deleteBookComplete)
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map { $0.isDeletingBook || $0.isDeletingRecord }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDeleting in
                if isDeleting {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map { $0.deleteRecordCompleted }
            .removeDuplicates()
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.logScreenView(name: GATracking.RecordFlow.deleteComplete)
                self?.viewModel.send(.initDeleteRecordValue)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .filter { $0.shareTriggered }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let item = state.shareItem else { return }
                self?.coordinator?.goToShareView(item: item)
                self?.viewModel.send(.shareHandled)
            }
            .store(in: &cancellable)
    }
    
}

private extension BookDetailViewController {
    struct ItemsAndTotal: Equatable {
        let itemIDs: [String]
        let items: [BookDetailItem]
        let total: Int
    }
    
    func presentBookRegistration(_ book: Book? = nil) {
        guard let book = book else { return }
        
        let statusView = BookRegistrationStatusView()
        statusView.setInitialSelection(.from(book.userBookStatus ?? .beforeRegistration))
        
        let sheet = BKBottomSheetViewController(
            title: "도서 상태",
            style: .leadingCloseButton,
            suppliedContentStyle: .lower(statusView),
            buttonConfiguration: .singleFullButton(
                title: "변경하기"
            ) { [weak self] in
                guard let selected = statusView.selectedStatus else { return }
                self?.dismiss(animated: true)
                self?.viewModel.send(.upsert(isbn: book.isbn, status: selected))
            }
        )
        let currentRegistrationStatus: BookRegistrationStatus = .from(book.userBookStatus ?? .beforeRegistration)
        let initialButtonEnabled = currentRegistrationStatus != statusView.selectedStatus
        sheet.button?.primaryButton?.isEnabled = initialButtonEnabled

        statusView.onSelected = { [weak sheet, weak statusView, currentRegistrationStatus] in
            let isDifferentFromCurrent = (statusView?.selectedStatus != .some(currentRegistrationStatus))
            sheet?.button?.primaryButton?.isEnabled = isDifferentFromCurrent
        }
        
        sheet.show(from: self, animated: true)
    }
    
    func presentBookDetailSortMenu(_ currentOption: SortOption) {
        let sheet = BKBottomSheetViewController.makeBookDetailSortMenuSheet(
            selectedOption: currentOption,
            confirmAction: { [weak self] option in
                self?.viewModel.send(.changeSortOption(option))
                self?.dismiss(animated: true)
            }
        )
        sheet.show(from: self, animated: true)
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
    
    func presentNoteMoreMenu(recordId: String) {
        let sheet = BKBottomSheetViewController.makeMoreMenuSheet(
            onShare: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.handleNoteShareButtonTapped(recordId: recordId)
                }
            },
            onEdit: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.handleNoteEditButtonTapped(recordId: recordId)
                }
            },
            onDelete: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.handleNoteDeleteButtonTapped(recordId: recordId)
                }
            }
        )
        
        sheet.show(from: self, animated: true)
    }
    
    func presentDeletionConfirmDialog(recordId: String = "") {
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
                        if recordId.isEmpty {
                            self.viewModel.send(.deleteBookButtonTapped)
                            self.logScreenView(name: GATracking.HomeAndLibrary.deleteBook)
                        } else {
                            self.viewModel.send(.deleteRecordButtonTapped(recordId))
                            self.logScreenView(name: GATracking.RecordFlow.delete)
                        }
                    }
                }
            )
        )
        let dialogViewController = BKDialogViewController(dialog: dialog)
        present(dialogViewController, animated: true)
    }
    
    @objc func handleMoreButtonTapped() {
        presentBookMoreMenu()
    }
    
    func handleNoteShareButtonTapped(recordId: String) {
        viewModel.send(.shareButtonTapped(recordId))
    }
    
    func handleNoteEditButtonTapped(recordId: String) {
        coordinator?.didTapEditButton(recordId: recordId, from: self)
    }
    
    func handleNoteDeleteButtonTapped(recordId: String) {
        presentDeletionConfirmDialog(recordId: recordId)
    }
    
    func handleDeleteButtonTapped() {
        presentDeletionConfirmDialog()
    }
}

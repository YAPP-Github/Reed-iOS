// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import UIKit

enum BookDetailViewEvent: Equatable {
    case didTapStatusButton
    case didTapSortMenuButton(SortOption)
}

final class BookDetailViewController: BaseViewController<BookDetailView> {
    override var bkNavigationTitle: String { "" }
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .standard(viewController: self)
    }
    
    weak var coordinator: BookDetailCoordinator?
    
    private var cancellable = Set<AnyCancellable>()
    let viewModel: AnyViewBindableViewModel<BookDetailViewModel.State, BookDetailViewModel.Action>
    
    init(viewModel: BookDetailViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func viewDidLoad() {
        viewModel.send(.onAppear)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func bindAction() {
        contentView.eventPublisher
            .filter { $0 == .didTapStatusButton }
            .sink { [weak self] _ in
                self?.presentBookRegistration(with: "")
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
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { $0.items }
            .removeDuplicates()
            .sink { [weak self] in
                self?.contentView.applySnapshot(with: $0)
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
    }
}

private extension BookDetailViewController {
    func presentBookRegistration(with isbn: String) {
        let statusView = BookRegistrationStatusView()
        let sheet = BKBottomSheetViewController(
            title: "도서 상태",
            style: .leadingCloseButton,
            suppliedContentStyle: .lower(statusView),
            buttonConfiguration: .singleFullButton(
                title: "변경하기"
            ) { [weak self] in
                self?.dismiss(animated: true)
            }
        )
        sheet.button?.primaryButton?.isEnabled = false
        statusView.onSelected = {
            sheet.button?.primaryButton?.isEnabled = true
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
}

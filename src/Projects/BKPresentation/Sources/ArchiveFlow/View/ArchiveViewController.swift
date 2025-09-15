// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import Combine
import UIKit

enum ArchiveViewEvent: Equatable {
    case viewWillAppear
    case chipTapped(index: Int)
    case bookTapped(book: ArchiveBook)
    case loginButtonTapped
    case loadNextPage
}

final class ArchiveViewController: BaseViewController<ArchiveView>, ScreenLoggable {
    var screenName: String = GATracking.HomeAndLibrary.libraryMain
    weak var coordinator: (ArchiveCoordinator & AuthenticationRequiredNotifying)?
    
    override var bkNavigationTitle: String {
        return "내 서재"
    }
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        return .main(
            viewController: self,
            target: self,
            searchAction: #selector(searchButtonTapped),
            gearAction: #selector(settingsButtonTapped)
        )
    }
    
    private var cancellable = Set<AnyCancellable>()
    let viewModel: AnyViewBindableViewModel<ArchiveViewModel.State, ArchiveViewModel.Action>
    
    init(viewModel: ArchiveViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.send(.onAppear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logScreenView()
    }
    
    override func bindAction() {
        contentView.events
            .sink { [weak self] event in
                switch event {
                case .chipTapped(let index):
                    self?.viewModel.send(.chipTapped(index: index))
                case .bookTapped(let book):
                    self?.handleBookTapped(book)
                case .loadNextPage:
                    self?.viewModel.send(.loadNextPage)
                case .loginButtonTapped:
                    self?.coordinator?.notifyAuthenticationRequired(onFinish: { [weak self] in
                        self?.viewModel.send(.onAppear)
                    })
                default:
                    break
                }
            }
            .store(in: &cancellable)
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                let (chips, books) = self?.extractData(from: state) ?? ([], [])
                self?.contentView.updateData(chips: chips, books: books)
            }
            .store(in: &cancellable)
    }
    
    private func extractData(from state: ArchiveViewModel.State) -> ([ChipData], [ArchiveBook]) {
        switch state.archiveState {
        case .empty(let chips):
            return (chips, [])
        case .books(let chips, let books):
            return (chips, books)
        }
    }
    
    // MARK: - Navigation Actions
    @objc
    private func searchButtonTapped() {
        if AccessModeCenter.shared.mode.value == .guest {
            coordinator?.handleError(.unauthorized)
        } else {
            coordinator?.didTapSearchButton()
        }
    }
    
    @objc
    private func settingsButtonTapped() {
        coordinator?.didTapSettingButton()
    }
    
    // MARK: - Private Methods
    private func handleBookTapped(_ book: ArchiveBook) {
        coordinator?.didTapBookDetailButton(isbn: book.isbn, userBookId: book.bookId)
    }
}

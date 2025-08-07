// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import UIKit

enum HomeViewEvent: Equatable {
    case didTapRecordButton(String)
    case didTapBook(String)
    case didTapSearchButton
    case didTapEmptyBook
}

final class HomeViewController: BaseViewController<HomeView> {
    weak var coordinator: MainFlowCoordinator?
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .home(
            viewController: self,
            target: self,
            gearAction: #selector(goToSettingViewController)
        )
    }
    
    override var bkNavigationTitle: String {
        return "Reed"
    }
    
    private var cancellable: Set<AnyCancellable> = []
    private let viewModel: AnyViewBindableViewModel<HomeViewModel.State, HomeViewModel.Action>
    
    init(viewModel: HomeViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        viewModel.send(.onAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.shadowImage = nil
    }
    
    override func bindAction() {
        contentView.eventPublisher
            .sink { [weak self] event in
                switch event {
                case .didTapBook(let _):
                    self?.coordinator?.didTapBookDetailButton()
                case .didTapRecordButton(let bookId):
                    self?.coordinator?.didTapNoteButton(bookId: bookId)
                case .didTapSearchButton:
                    self?.coordinator?.didTapSearchButton()
                case .didTapEmptyBook:
                    self?.coordinator?.didTapSearchButton()
                }
            }
            .store(in: &cancellable)
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .map { $0.homeInfos }
            .sink { [weak self] homeInfos in
                self?.contentView.updateBooks(homeInfos)
            }
            .store(in: &cancellable)
    }
    
    @objc private func goToSettingViewController() {
        coordinator?.didTapSettingButton()
    }
}

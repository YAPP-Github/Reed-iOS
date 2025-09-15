// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import BKDomain
import Combine
import UIKit

enum HomeViewEvent: Equatable {
    case didTapRecordButton(String)
    case didTapBook(isbn: String, userBookId: String)
    case didTapSearchButton
    case didTapEmptyBook
}

final class HomeViewController: BaseViewController<HomeView>, ScreenLoggable {
    var screenName: String = GATracking.HomeAndLibrary.homeMain
    weak var coordinator: MainFlowCoordinator?
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .homeWithImage(
            viewController: self,
            image: BKImage.Logos.smallLogo,
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
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.shadowImage = nil
        
        viewModel.send(.onDisappear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logScreenView()
    }
    
    override func bindAction() {
        contentView.eventPublisher
            .sink { [weak self] event in
                switch event {
                case .didTapBook(let isbn, let userBookId):
                    self?.coordinator?.didTapBookDetailButton(isbn: isbn, userBookId: userBookId)
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
            .map(\.shouldPlayAnimation)
            .removeDuplicates()
            .sink { [weak self] shouldPlayAnimation in
                self?.contentView.playAnimation(shouldPlayAnimation)
            }
            .store(in: &cancellable)

        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map(\.error)
            .removeDuplicates()
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.coordinator?.handleError(error)
                self?.viewModel.send(.errorHandled)
            }
            .store(in: &cancellable)
    }
    
    @objc private func goToSettingViewController() {
        coordinator?.didTapSettingButton()
    }
}

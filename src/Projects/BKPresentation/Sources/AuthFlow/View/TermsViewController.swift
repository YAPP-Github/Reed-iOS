// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import SafariServices
import UIKit

final class TermsViewController: BaseViewController<TermsView> {
    weak var coordinator: TermsCoordinator?
    
    let viewModel: AnyViewBindableViewModel<TermsViewModel.State, TermsViewModel.Action>
    private var cancellables = Set<AnyCancellable>()
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .standard(
            viewController: self,
            rightButton: .none
        )
    }
    
    override var bkNavigationTitle: String {
        return ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    init(viewModel: TermsViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func bindAction() {
        viewModel.send(.viewDidLoad)
        
        contentView.events
            .sink { [weak self] event in
                switch event {
                case .agreeAllTapped:
                    self?.viewModel.send(.agreeAllTapped)
                case .termTapped(let index):
                    self?.viewModel.send(.termTapped(index: index))
                case .startButtonTapped:
                    self?.viewModel.send(.startButtonTapped)
                case .showTermDetail(let docsType):
                    self?.coordinator?.presentWeb(url: docsType.url)
                }
            }
            .store(in: &cancellables)
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.contentView.update(with: state)
            }
            .store(in: &cancellables)
        
        viewModel.statePublisher
            .map(\.error)
            .removeDuplicates()
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.coordinator?.handleError(error)
            }
            .store(in: &cancellables)
        
        viewModel.statePublisher
            .map(\.didAgreementSucceed)
            .removeDuplicates()
            .filter { $0 == true }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.coordinator?.popAndFinish()
            }
            .store(in: &cancellables)
    }
}

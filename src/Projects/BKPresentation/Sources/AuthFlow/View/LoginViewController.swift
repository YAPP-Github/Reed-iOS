// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine
import Foundation
import UIKit

final class LoginViewController: BaseViewController<LoginView> {
    weak var coordinator: LoginCoordinator?
    
    var cancellable: Set<AnyCancellable> = []
    let viewModel: AnyViewBindableViewModel<LoginViewModel.State, LoginViewModel.Action>
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .main(
            viewController: self,
            target: self,
            searchAction: #selector(dummyFunc),
            gearAction: #selector(dummyFunc)
        )
    }
    
    override var bkNavigationTitle: String {
        return "로그인"
    }
    
    init(viewModel: LoginViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func bindAction() {
        contentView.eventPublisher
            .sink { event in
                switch event {
                case .loginButtonTapped(let provider):
                    if provider == .apple {
                        self.viewModel.send(.appleLoginButtonTapped)
                    } else if provider == .kakao {
                        self.viewModel.send(.kakaoLoginButtonTapped)
                    }
                }
            }
            .store(in: &cancellable)
    }
    
    override func bindState() {
        viewModel.statePublisher
            .map { $0.errorMessage }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { error in
                print("error occurred: \(String(describing: error))")
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map { $0.latestProvider }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { provider in
                print("latestProvider: \(String(describing: provider))")
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map { $0.isLoggedIn }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoggedIn in
                print("authentication status: \(isLoggedIn)")
                self?.coordinator?.popAndFinish()
            }
            .store(in: &cancellable)
    }
    
    @objc func dummyFunc() {}
}

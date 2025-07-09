// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine
import Foundation
import UIKit

final class LoginViewController: BaseViewController<LoginView> {
    var cancellable: Set<AnyCancellable> = []
    let viewModel: AnyViewBindableViewModel<LoginViewModel.State, LoginViewModel.Action>
    weak var coordinator: LoginCoordinator?
    
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
                case .logoutButtonTapped:
                    self.viewModel.send(.logoutButtonTapped)
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
            .map { ($0.latestProvider, $0.isLoggedIn) }
            .removeDuplicates { $0 == $1 }
            .receive(on: DispatchQueue.main)
            .sink { (provider, isLoggedIn) in
                self.contentView.updateStatusView(provider: provider ?? "No Provider", status: isLoggedIn)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map { $0.isLoggedIn }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { isLoggedIn in
                print("authentication status: \(isLoggedIn)")
            }
            .store(in: &cancellable)
    }
}

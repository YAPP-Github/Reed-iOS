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
        .standard(
            viewController: self,
            rightButton: .none
        )
    }
    
    override var bkNavigationTitle: String {
        return ""
    }
    
    init(viewModel: LoginViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
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
            .sink { [weak self] error in
                self?.coordinator?.presentCustomErrorAlert(
                    title: "로그인 오류",
                    subtitle: """
                    예기치 않은 오류가 발생했습니다.
                    다시 로그인 해주세요.
                    """,
                    onConfirm: {}
                )
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .filter { $0.isLoggedIn == true }
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.coordinator?.popAndFinish()
            }
            .store(in: &cancellable)
    }
}

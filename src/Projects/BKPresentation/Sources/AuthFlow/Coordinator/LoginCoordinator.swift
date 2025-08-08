// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Foundation
import UIKit

final class LoginCoordinator: Coordinator, FinishNotifying {
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var onFinish: (() -> Void)?
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        let loginViewController = LoginViewController(viewModel: LoginViewModel())
        loginViewController.coordinator = self
        navigationController.setViewControllers([loginViewController], animated: true)
    }
}

extension LoginCoordinator {
    func presentLoginError() {
        let dialog = BKDialog(
            title: "로그인 오류",
            subtitle: """
            예기치 않은 오류가 발생했습니다.
            다시 로그인 해주세요.
            """,
            config: .init(
                leftButtonTitle: "확인",
                leftButtonAction: { [weak self] in
                    self?.presentedViewController?.dismiss(animated: true)
                })
            )
        
        let dialogViewController = BKDialogViewController(dialog: dialog)
        topViewController?.present(dialogViewController, animated: true)
    }
}

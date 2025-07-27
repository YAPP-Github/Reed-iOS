// Copyright © 2025 Booket. All rights reserved

import Foundation
import UIKit
import SafariServices

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
        navigationController.pushViewController(loginViewController, animated: true)
    }
}

extension LoginCoordinator {
    /// 약관동의 화면으로 이동
    func goToTermsViewController() {
        let termsViewController = TermsViewController(viewModel: TermsViewModel())
        termsViewController.coordinator = self
        navigationController.pushViewController(termsViewController, animated: true)
    }
    
    /// MainFlow로 이동
    func goToMainFlow() {
        onFinish?()
    }
    
    /// webview 보여주기 -> 추후 WebView로 전환해도됨(현재 사파리)
    func showWebView(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        navigationController.present(safariViewController, animated: true)
    }
}

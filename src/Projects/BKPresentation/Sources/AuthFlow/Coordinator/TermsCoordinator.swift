// Copyright © 2025 Booket. All rights reserved

import UIKit

final class TermsCoordinator: Coordinator, FinishNotifying {
    var onFinish: (() -> Void)?
    
    weak var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(
        parentCoordinator: Coordinator?,
        navigationController: UINavigationController
    ) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
    }
    
    func start() {
        let termsViewController = TermsViewController(viewModel: TermsViewModel())
        termsViewController.coordinator = self
        navigationController.pushViewController(termsViewController, animated: true)
    }
}

extension TermsCoordinator: AuthenticationRequiredNotifying, ErrorHandleable, URLPresenting {
    func notifyAuthenticationRequired(onFinish: (() -> Void)?) {
        (parentCoordinator as? AuthenticationRequiredNotifying)?.notifyAuthenticationRequired(onFinish: onFinish)
    }
}

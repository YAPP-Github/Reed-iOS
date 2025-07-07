// Copyright © 2025 Booket. All rights reserved

import Foundation
import UIKit

// TODO: - Placeholder 대신 넣은 파일입니다. 실제 MainFlow 개발 시작 시 삭제하세요.
final class MainFlowCoordinator: Coordinator {
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
    
    func start() { }
}

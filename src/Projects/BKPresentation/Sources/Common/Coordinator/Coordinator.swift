// Copyright © 2025 Booket. All rights reserved

import UIKit

/// Flow 제어 시, `onFinish`를 참고하고 사용해주세요.
public protocol Coordinator: AnyObject {
    // MARK: - Properties
    var parentCoordinator: (any Coordinator)? { get set }
    var childCoordinators: [any Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    // MARK: - Methods
    func start()
}

// MARK: - Default Implementation
public extension Coordinator {
    var topViewController: UIViewController? {
        return navigationController.topViewController
    }
    
    var presentedViewController: UIViewController? {
        return navigationController.presentedViewController
    }
    
    func didFinish() {
        finishAllChildCoordinators()
        parentCoordinator?.removeChildCoordinator(self)
        
        if let self = self as? FinishNotifying {
            self.onFinish?()
        }
    }
    
    /// 기본 구현 메소드 여러 개를 가지고 유기적으로 구현되었습니다. 스택 정리 시 이 메소드만 사용해도 무방합니다.
    func popAndFinish(
        animated: Bool = true
    ) {
        guard navigationController.viewControllers.count > 1 else {
            didFinish()
            return
        }
        navigationController.popViewController(animated: animated)
        didFinish()
    }
    
    func addChildCoordinator(
        _ coordinator: any Coordinator
    ) {
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
    }
    
    func removeChildCoordinator(
        _ child: (any Coordinator)?
    ) {
        for (idx, coordinator) in childCoordinators.enumerated() where coordinator === child {
            childCoordinators.remove(at: idx)
            break
        }
    }
    
    func finishAllChildCoordinators() {
        for coordinator in childCoordinators {
            coordinator.finishAllChildCoordinators()
        }
        childCoordinators.removeAll()
    }
    
    func firstAncestor<T>(
        ofType type: T.Type
    ) -> T? {
        var current: Coordinator? = self
        while let parent = current?.parentCoordinator {
            if let match = parent as? T { return match }
            current = parent
        }
        return nil
    }
}

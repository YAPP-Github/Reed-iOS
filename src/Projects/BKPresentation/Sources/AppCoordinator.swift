// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import BKDesign
import Combine
import Foundation
import UIKit

public final class AppCoordinator: Coordinator, AuthenticationRequiredNotifying, ScreenLoggable {
    public var screenName: String = GATracking.OnboardingAndAuth.splash

    public weak var parentCoordinator: Coordinator?
    public var childCoordinators = [Coordinator]()
    public var navigationController: UINavigationController
    
    private let authStateUseCase: AuthStateUseCase
    private let onboardingCheckUseCase: OnboardingCheckUseCase
    private let markOnboardingSeenUseCase: MarkOnboardingSeenUseCase
    private let appVersionUseCase: AppVersionUseCase
    private var cancellable: Set<AnyCancellable> = []
    
    public init(
        navigationController: UINavigationController,
        authStateUseCase: AuthStateUseCase,
        onboardingCheckUseCase: OnboardingCheckUseCase,
        markOnboardingSeenUseCase: MarkOnboardingSeenUseCase,
        appVersionUseCase: AppVersionUseCase
    ) {
        self.navigationController = navigationController
        self.authStateUseCase = authStateUseCase
        self.onboardingCheckUseCase = onboardingCheckUseCase
        self.markOnboardingSeenUseCase = markOnboardingSeenUseCase
        self.appVersionUseCase = appVersionUseCase
    }
    
    public func start() {
        logGoogleAnalytics()
        checkAppUpdate()
    }
    
    func notifyAuthenticationRequired(onFinish: (() -> Void)?) {
        presentAuthFlow(animated: true, onFinishAuth: onFinish)
    }
    
    private func checkAppUpdate() {
        Publishers.Zip(
            appVersionUseCase.execute().setFailureType(to: Error.self),
            appVersionUseCase.executeRecentVersion()
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            if case .failure = completion {
                self?.proceedWithAppFlow()
            }
        }, receiveValue: { [weak self] currentVersionString, latestVersionString in
            guard let self = self,
                  let currentVersion = Version(currentVersionString),
                  let latestVersion = Version(latestVersionString)
            else {
                self?.proceedWithAppFlow()
                return
            }
            
            if currentVersion.isMajorOrMinorUpdateRequired(from: latestVersion) {
                self.presentUpdateSheet()
            } else {
                self.proceedWithAppFlow()
            }
        })
        .store(in: &cancellable)
    }
    
    private func proceedWithAppFlow() {
        onboardingCheckUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] didSeeOnboarding in
                guard let self else { return }
                if didSeeOnboarding {
                    self.startMainFlow()
                    self.checkAuthAndRoute()
                } else {
                    self.startOnboardingFlow()
                }
            }
            .store(in: &cancellable)
    }
    
    private func presentAuthFlow(
        animated: Bool,
        onFinishAuth: (() -> Void)?
    ) {
        let authNavigationController = UINavigationController()
        authNavigationController.modalPresentationStyle = .fullScreen
        authNavigationController.isModalInPresentation = true
        let loginCoordinator = LoginCoordinator(
            parentCoordinator: self,
            navigationController: authNavigationController
        )
        
        loginCoordinator.onFinish = { [weak self] in
            guard let self else { return }
            
            self.navigationController.dismiss(animated: animated)
            AccessModeCenter.shared.mode.send(.member)
            self.checkAuthAndRoute()
            onFinishAuth?()
        }
        
        addChildCoordinator(loginCoordinator)
        loginCoordinator.start()
        
        navigationController.present(authNavigationController, animated: animated)
    }
    
    private func startMainFlow() {
        let tabBarCoordinator = TabBarCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        
        addChildCoordinator(tabBarCoordinator)
        tabBarCoordinator.start()
    }
    
    private func transitionToAuthenticatedMain() {
        guard !(navigationController.viewControllers.first is UITabBarController) else { return }
        navigationController.viewControllers.removeAll()
        startMainFlow()
    }
    
    private func startTermsFlow() {
        let termsCoordinator = TermsCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        termsCoordinator.onFinish = { [weak self] in
            AccessModeCenter.shared.mode.send(.member)
            self?.navigationController.dismiss(animated: true)
        }
        addChildCoordinator(termsCoordinator)
        termsCoordinator.start()
    }
    
    private func startOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(
            parentCoordinator: self,
            navigationController: navigationController
        )
        onboardingCoordinator.onFinish = { [weak self] in
            guard let self else { return }
            self.markOnboardingSeenUseCase.execute()
            self.startMainFlow()
            self.checkAuthAndRoute()
        }
        addChildCoordinator(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    private func checkAuthAndRoute() {
        authStateUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        AccessModeCenter.shared.mode.send(.member)
                    case .failure:
                        AccessModeCenter.shared.mode.send(.guest)
                    }
                },
                receiveValue: { [weak self] userProfile in
                    guard let self else { return }
                    if userProfile.termsAgreed {
                        self.transitionToAuthenticatedMain()
                    } else {
                        self.startTermsFlow()
                    }
                }
            )
            .store(in: &cancellable)
    }
    
    private func presentUpdateSheet() {
        let dialog = BKDialog(
            title: "최신 버전이 출시되었습니다",
            subtitle: "최적의 사용 환경을 위해 업데이트해주세요.",
            config: .init(
                leftButtonTitle: "업데이트 하기",
                leftButtonAction: AppStoreLinker.openAppStore
            )
        )
        
        let dialogViewController = BKDialogViewController(dialog: dialog)
        dialogViewController.isModalInPresentation = true
        DispatchQueue.main.async {
            self.navigationController.present(dialogViewController, animated: true)
        }
    }
}

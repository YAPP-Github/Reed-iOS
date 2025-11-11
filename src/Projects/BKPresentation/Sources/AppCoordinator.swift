// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import BKDesign
import Combine
import Foundation
import UIKit
import UserNotifications

public final class AppCoordinator: Coordinator, AuthenticationRequiredNotifying, ScreenLoggable {
    public var screenName: String = GATracking.OnboardingAndAuth.splash

    public weak var parentCoordinator: Coordinator?
    public var childCoordinators = [Coordinator]()
    public var navigationController: UINavigationController
    
    private let authStateUseCase: AuthStateUseCase
    private let onboardingCheckUseCase: OnboardingCheckUseCase
    private let markOnboardingSeenUseCase: MarkOnboardingSeenUseCase
    private let appVersionUseCase: AppVersionUseCase
    private let fetchRemoteAppVersionUseCase: FetchRemoteAppVersionUseCase
    private let syncFCMTokenUseCase: SyncFCMTokenUseCase
    private var cancellable: Set<AnyCancellable> = []

    public init(
        navigationController: UINavigationController,
        authStateUseCase: AuthStateUseCase,
        onboardingCheckUseCase: OnboardingCheckUseCase,
        markOnboardingSeenUseCase: MarkOnboardingSeenUseCase,
        appVersionUseCase: AppVersionUseCase,
        fetchRemoteAppVersionUseCase: FetchRemoteAppVersionUseCase,
        syncFCMTokenUseCase: SyncFCMTokenUseCase
    ) {
        self.navigationController = navigationController
        self.authStateUseCase = authStateUseCase
        self.onboardingCheckUseCase = onboardingCheckUseCase
        self.markOnboardingSeenUseCase = markOnboardingSeenUseCase
        self.appVersionUseCase = appVersionUseCase
        self.fetchRemoteAppVersionUseCase = fetchRemoteAppVersionUseCase
        self.syncFCMTokenUseCase = syncFCMTokenUseCase
    }
    
    public func start() {
        logGoogleAnalytics()
        upsertFCMTokenIfNeeded()
        checkAppUpdate()
    }
    
    func notifyAuthenticationRequired(onFinish: (() -> Void)?) {
        presentAuthFlow(animated: true, onFinishAuth: onFinish)
    }
    
    private func upsertFCMTokenIfNeeded() {
        syncFCMTokenUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        Log.error("Failed to sync FCM token: \(error)", logger: AppLogger.network)
                    }
                },
                receiveValue: { _ in
                    Log.debug("FCM token sync completed", logger: AppLogger.network)
                }
            )
            .store(in: &cancellable)
    }

    private func checkAppUpdate() {
        Publishers.Zip(
            appVersionUseCase.execute().setFailureType(to: Error.self),
            fetchRemoteAppVersionUseCase.execute()
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            if case .failure = completion {
                self?.proceedWithAppFlow()
            }
        }, receiveValue: { [weak self] currentVersionString, remoteVersions in
            guard let self = self,
                  let currentVersion = Version(currentVersionString),
                  let minimumVersion = Version(remoteVersions.minimumRequiredVersion),
                  let latestVersion = Version(remoteVersions.latestVersion)
            else {
                self?.proceedWithAppFlow()
                return
            }
            
            Log.debug("currentVersionString: \(currentVersionString)", logger: AppLogger.ui)
            Log.debug("minimumRequiredVersion: \(remoteVersions.minimumRequiredVersion)", logger: AppLogger.ui)
            Log.debug("latestVersion: \(remoteVersions.latestVersion)", logger: AppLogger.ui)
            
            if currentVersion < minimumVersion {
                self.presentUpdateSheet() // 강업
            }
            else if currentVersion < latestVersion {
                self.presentUpdateSheet(isForced: false) // 권장
                self.proceedWithAppFlow()
            }
            else {
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
            self.requestNotificationPermissionIfNeeded()
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
    
    private func presentUpdateSheet(isForced: Bool = true) {
        var dialog: BKDialog?
        
        if isForced {
            dialog = BKDialog(
                title: "최신 버전이 출시되었습니다",
                subtitle: "최적의 사용 환경을 위해 업데이트해주세요.",
                config: .init(
                    leftButtonTitle: "업데이트 하기",
                    leftButtonAction: AppStoreLinker.openAppStore
                )
            )
        } else {
            dialog = BKDialog(
                title: "최신 버전이 출시되었습니다",
                subtitle: "최적의 사용 환경을 위해 업데이트해주세요.",
                config: .init(
                    leftButtonTitle: "업데이트 하기",
                    leftButtonAction: AppStoreLinker.openAppStore,
                    rightButtonTitle: "나중에 하기",
                    rightButtonAction: { [weak self] in
                        self?.navigationController.dismiss(animated: true)
                    }
                )
            )
        }
        
        guard let dialog else { return }
        let dialogViewController = BKDialogViewController(dialog: dialog)
        dialogViewController.isModalInPresentation = true
        DispatchQueue.main.async {
            self.navigationController.present(dialogViewController, animated: true)
        }
    }

    private func requestNotificationPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            // 아직 권한을 요청하지 않았을 때만 요청
            guard settings.authorizationStatus == .notDetermined else { return }

            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                guard granted else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

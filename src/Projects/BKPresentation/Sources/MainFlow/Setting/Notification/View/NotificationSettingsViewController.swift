// Copyright © 2025 Booket. All rights reserved

import BKCore
import Combine
import UIKit
import UserNotifications

final class NotificationSettingsViewController: BaseViewController<NotificationSettingsView> {
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        return .standard(
            viewController: self
        )
    }

    override var bkNavigationTitle: String {
        return "알림"
    }

    weak var coordinator: (NotificationSettingsCoordinator & URLPresenting)?
    private var cancellable = Set<AnyCancellable>()
    let viewModel: AnyViewBindableViewModel<NotificationSettingsViewModel.State, NotificationSettingsViewModel.Action>
    private var isInitialLoad = true

    init(viewModel: NotificationSettingsViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewActions()
        observeAppLifecycle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        checkNotificationAuthorization()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    private func setupViewActions() {
        contentView.onNotificationToggleChanged = { [weak self] isEnabled in
            self?.viewModel.send(.notificationToggleTapped(isEnabled))
        }

        contentView.onPermissionRequestViewTapped = { [weak self] in
            self?.openNotificationSettings()
        }
    }

    private func openNotificationSettings() {
        coordinator?.presentApp(
            url: URL(string: UIApplication.openNotificationSettingsURLString)
        )
    }

    private func observeAppLifecycle() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.checkNotificationAuthorization()
            }
            .store(in: &cancellable)
    }

    private func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized
                self?.viewModel.send(.systemNotificationAuthorizationChecked(isAuthorized))
            }
        }
    }

    override func bindAction() {
        viewModel.send(.onAppear)
    }

    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                // 초기 로드시에는 애니메이션 없이 즉시 설정
                let shouldAnimate = !self.isInitialLoad
                self.contentView.updateNotificationToggle(isEnabled: state.notificationEnabled, animated: shouldAnimate)
                self.contentView.updatePermissionRequestVisibility(
                    shouldShow: !state.systemNotificationAuthorized,
                    animated: shouldAnimate
                )
                self.isInitialLoad = false
            }
            .store(in: &cancellable)
    }
}

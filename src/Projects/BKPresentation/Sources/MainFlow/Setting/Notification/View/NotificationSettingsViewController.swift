// Copyright © 2025 Booket. All rights reserved

import BKCore
import Combine
import UIKit

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
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

    override func bindAction() {
        viewModel.send(.onAppear)
    }

    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { $0.notificationEnabled }
            .sink { [weak self] notificationEnabled in
                guard let self = self else { return }
                // 초기 로드시에는 애니메이션 없이 즉시 설정
                let shouldAnimate = !self.isInitialLoad
                self.contentView.updateNotificationToggle(isEnabled: notificationEnabled, animated: shouldAnimate)
                self.isInitialLoad = false
            }
            .store(in: &cancellable)
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import Combine
import Foundation
import UIKit

enum SettingViewEvent {
    case logoutButtonTapped
    case withdrawalButtonTapped
    case firstMenuTapped(FirstMenuItem)
}

final class SettingViewController: BaseViewController<SettingView> {
    weak var coordinator: SettingCoordinator?
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        return .standard(
            viewController: self
        )
    }
    
    override var bkNavigationTitle: String {
        return "설정"
    }
    
    private var cancellable = Set<AnyCancellable>()
    let viewModel: AnyViewBindableViewModel<SettingViewModel.State, SettingViewModel.Action>
    
    init(viewModel: SettingViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func bindAction() {
        viewModel.send(.onAppear)
        contentView.eventPublisher
            .sink { [weak self] event in
                switch event {
                case .logoutButtonTapped:
                    self?.presentLogoutDialog()
                case .withdrawalButtonTapped:
                    self?.presentWithdrawalSheet()
                case .firstMenuTapped(let item):
                    switch item {
                    case .privacy:
                        self?.coordinator?.presentWeb(url: DocsType.privacy.url)
                    case .term:
                        self?.coordinator?.presentWeb(url: DocsType.terms.url)
                    case .license:
                        self?.coordinator?.presentWeb(url: DocsType.licenses.url)
                    case .version:
                        break
                    }
                }
            }
            .store(in: &cancellable)
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map {( first: $0.firstMenuItems, second: $0.secondMenuItems )}
            .sink { [weak self] menus in
                self?.contentView.apply(
                    firstMenus: menus.first,
                    secondMenus: menus.second
                )
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { $0.appVersion }
            .removeDuplicates()
            .sink { [weak self] version in
                self?.contentView.setAppVersion(version)
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { $0.isLoggedOut }
            .filter { $0 }
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.coordinator?.notifyParentSessionExpired()
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .map { $0.isLoading }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
            .store(in: &cancellable)
                   
        viewModel.statePublisher
            .map(\.error)
            .removeDuplicates()
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.coordinator?.handleError(error)
                self?.viewModel.send(.errorHandled)
            }
            .store(in: &cancellable)
    }
    
    @objc func dummyFunc() {}
}

private extension SettingViewController {
    func presentLogoutDialog() {
        let dialog = BKDialog(
            title: "정말 로그아웃 하시겠습니까?",
            subtitle: "",
            config: BKDialogConfiguration(
                leftButtonTitle: "취소",
                leftButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                },
                rightButtonTitle: "로그아웃",
                rightButtonAction: { [weak self] in
                    self?.viewModel.send(.logoutButtonTapped)
                    self?.dismiss(animated: true)
                }
            )
        )
        let dialogViewController = BKDialogViewController(dialog: dialog)
        present(dialogViewController, animated: true)
    }
    
    func presentWithdrawalSheet() {
        let sheet = BKBottomSheetViewController.makeWithdrawalSheet(
            title: "정말 탈퇴하시겠어요?",
            subtitle: """
            탈퇴 시, 개인 정보와 그동안의 독서기록이
            모두 삭제되며 복구가 어렵습니다. 
            """,
            agreementText: "확인하였으며 이에 동의합니다",
            cancelAction: { [weak self] in self?.dismiss(animated: true) },
            confirmAction: { [weak self] in
                Log.debug("[WithdrawalSheet] confirmed", logger: AppLogger.ui)
                // self?.viewModel.send()
            }
        )
        
        sheet.show(from: self, animated: true)
    }
}

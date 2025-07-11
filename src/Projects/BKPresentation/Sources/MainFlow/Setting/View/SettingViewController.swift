// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

enum SettingViewEvent {
    case logoutButtonTapped
    case withdrawalButtonTapped
}

final class SettingViewController: BaseViewController<SettingView> {
    weak var coordinator: SettingCoordinator?
    
    private var cancellable = Set<AnyCancellable>()
    let viewModel: AnyViewBindableViewModel<SettingViewModel.State, SettingViewModel.Action>
    
    init(viewModel: SettingViewModel) {
        self.viewModel = AnyViewBindableViewModel(viewModel)
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "설정"
    }
    
    override func bindAction() {
        viewModel.send(.onAppear)
//        contentView.eventPublisher
//            .sink { event in
//                switch event {
//                case .logoutButtonTapped:
//                    viewModel.send()
//                case .withdrawalButtonTapped:
//                    viewModel.send()
//                }
//            }
//            .store(in: &cancellable)
    }
    
    override func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { ( first: $0.firstMenuItems, second: $0.secondMenuItems )}
            .sink { menus in
                self.contentView.apply(
                    firstMenus: menus.first,
                    secondMenus: menus.second
                )
            }
            .store(in: &cancellable)
        
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .map { $0.appVersion }
            .removeDuplicates()
            .sink { version in
                self.contentView.setAppVersion(version)
            }
            .store(in: &cancellable)
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

enum FirstMenuItem: String, CaseIterable {
    case privacy = "개인정보 처리방침"
    case term = "이용약관"
    case license = "오픈소스 라이선스"
    case version = "앱 버전"
    
    var title: String { rawValue }
}

enum SecondMenuItem: String, CaseIterable {
    case login = "로그인"
    case logout = "로그아웃"
    case withdraw = "회원탈퇴"
    
    var title: String { rawValue }
}

final class SettingViewModel: BaseViewModel {
    struct State: Equatable {
        var firstMenuItems = FirstMenuItem.allCases
        var secondMenuItems: [SecondMenuItem] = []
        var latestAppVersion: String = ""
        var appVersion: String = ""
        var isLoggedOut: Bool = false
        var isLoading: Bool = false
        var error: DomainError? = nil
        var isLoginRequired: Bool = false
        
        var isUpdateAvailable: Bool {
            appVersion.compare(latestAppVersion, options: .numeric) == .orderedAscending
        }
    }
    
    enum Action {
        case onAppear
        case accessModeChanged(AppAccessMode)
        case fetchAppVersionSuccessed(String)
        case fetchLatestAppVersionSucceeded(String)
        case loginButtonTapped
        case logoutButtonTapped
        case logoutSuccessed
        case errorOccured(DomainError)
        case errorHandled
        case withdrawButtonTapped
        case withdrawSuccessed
        case loginFlowFinished
    }
    
    enum SideEffect {
        case appVersion
        case fetchLatestAppVersion
        case logout
        case withdraw
    }
    
    @Published private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    @Autowired private var appVersionUseCase: AppVersionUseCase
    @Autowired private var logoutUseCase: LogoutUseCase
    @Autowired private var withdrawAccountUseCase: WithdrawAccountUseCase
    
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init() {
        bindSideEffects()
        
        AccessModeCenter.shared.mode
            .sink { [weak self] mode in
                self?.send(.accessModeChanged(mode))
            }
            .store(in: &cancellables)
    }
    
    func send(_ action: Action) {
        let (newState, effects) = reduce(action: action, state: state)
        state = newState
        effects.forEach { sideEffectSubject.send($0) }
    }
    
    func reduce(action: Action, state: State) -> (State, [SideEffect]) {
        var newState = state
        var effects: [SideEffect] = []
        
        switch action {
        case .onAppear:
            send(.accessModeChanged(AccessModeCenter.shared.mode.value))
            effects.append(.appVersion)
            effects.append(.fetchLatestAppVersion)
            
        case .accessModeChanged(let mode):
            if mode == .member {
                newState.secondMenuItems = [.logout, .withdraw]
            } else {
                newState.secondMenuItems = [.login]
            }

        case .fetchAppVersionSuccessed(let version):
            newState.appVersion = version
        
        case .fetchLatestAppVersionSucceeded(let latestVersion):
            newState.latestAppVersion = latestVersion
            
        case .loginButtonTapped:
            newState.isLoginRequired = true
            
        case .logoutButtonTapped:
            newState.isLoading = true
            effects.append(.logout)
            
        case .logoutSuccessed:
            newState.isLoading = false
            
        case .errorOccured(let error):
            newState.isLoading = false
            newState.error = error
            
        case .errorHandled:
            newState.error = nil
            
        case .withdrawButtonTapped:
            newState.isLoading = true
            effects.append(.withdraw)
            
        case .withdrawSuccessed:
            newState.isLoading = false
            newState.isLoggedOut = true
            
        case .loginFlowFinished:
            newState.isLoginRequired = false
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .appVersion:
            return appVersionUseCase.execute()
                .map(Action.fetchAppVersionSuccessed)
                .eraseToAnyPublisher()
            
        case .fetchLatestAppVersion:
            return appVersionUseCase.executeRecentVersion()
                .map { Action.fetchLatestAppVersionSucceeded($0) }
                .catch { error -> Just<Action> in
                    Log.debug("Failed to fetch latest app version: \(error)", logger: AppLogger.viewModel)
                    return Just(Action.fetchLatestAppVersionSucceeded(""))
                }
                .eraseToAnyPublisher()
            
        case .logout:
            return logoutUseCase.execute()
                .handleEvents(receiveOutput: { _ in
                    AccessModeCenter.shared.mode.send(.guest)
                })
                .map { _ in Action.logoutSuccessed }
                .catch { _ in Just(Action.errorOccured(.unauthorized)) }
                .eraseToAnyPublisher()
            
        case .withdraw:
            return withdrawAccountUseCase.execute()
                .handleEvents(receiveOutput: { _ in
                    AccessModeCenter.shared.mode.send(.guest)
                })
                .map { _ in Action.withdrawSuccessed }
                .catch { _ in Just(Action.errorOccured(.unauthorized)) }
                .eraseToAnyPublisher()
        }
    }
    
    private func bindSideEffects() {
        sideEffectSubject
            .flatMap { [weak self] effect in
                self?.handle(effect) ?? Empty().eraseToAnyPublisher()
            }
            .sink(receiveValue: send(_:))
            .store(in: &cancellables)
    }
}

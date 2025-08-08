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
    case logout = "로그아웃"
    case withdraw = "회원탈퇴"
    
    var title: String { rawValue }
}

final class SettingViewModel: BaseViewModel {
    struct State {
        var firstMenuItems = FirstMenuItem.allCases
        var secondMenuItems = SecondMenuItem.allCases
        var appVersion: String = ""
        var isLoggedOut: Bool = false
        var isLoading: Bool = false
        var error: DomainError? = nil
    }
    
    enum Action {
        case onAppear
        case fetchAppVersionSuccessed(String)
        case logoutButtonTapped
        case logoutSuccessed
        case errorOccured(DomainError)
        case errorHandled
        case withdrawButtonTapped
        case withdrawSuccessed
    }
    
    enum SideEffect {
        case appVersion
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
    }
    
    func send(_ action: Action) {
        let (newState, effects) = reduce(action: action, state: state)
        state = newState
        effects.forEach { sideEffectSubject.send($0) }
    }
    
    // TODO : withdraw 케이스에도 로딩 추가 필요 @dyk429
    func reduce(action: Action, state: State) -> (State, [SideEffect]) {
        var newState = state
        var effects: [SideEffect] = []
        
        switch action {
        case .onAppear:
            effects.append(.appVersion)
            
        case .fetchAppVersionSuccessed(let version):
            newState.appVersion = version
            
        case .logoutButtonTapped:
            newState.isLoading = true
            effects.append(.logout)
            
        case .logoutSuccessed:
            newState.isLoading = false
            newState.isLoggedOut = true
            
        case .errorOccured(let error):
            newState.isLoading = false
            newState.error = error
            newState.isLoggedOut = false
            
        case .errorHandled:
            newState.error = nil
            
        case .withdrawButtonTapped:
            newState.isLoading = true
            effects.append(.withdraw)
            
        case .withdrawSuccessed:
            newState.isLoading = false
            newState.isLoggedOut = true
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .appVersion:
            return appVersionUseCase.execute()
                .map(Action.fetchAppVersionSuccessed)
                .eraseToAnyPublisher()
        case .logout:
            return logoutUseCase.execute()
                .map { _ in Action.logoutSuccessed }
                .catch { _ in Just(Action.errorOccured(.unauthorized)) }
                .eraseToAnyPublisher()
            
        case .withdraw:
            return withdrawAccountUseCase.execute()
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

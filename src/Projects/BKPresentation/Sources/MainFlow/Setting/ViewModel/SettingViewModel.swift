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
    }
    
    enum Action {
        case onAppear
        case fetchAppVersionSuccessed(String)
//        case logoutButtonTapped
//        case withdrawButtonTapped
    }
    
    enum SideEffect {
        case appVersion
//        case logout
//        case withdraw
    }
    
    @Published private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    @Autowired private var appVersionUseCase: AppVersionUseCase
    
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
    
    func reduce(action: Action, state: State) -> (State, [SideEffect]) {
        var newState = state
        var effects: [SideEffect] = []
        
        switch action {
        case .onAppear:
            effects.append(.appVersion)
        case .fetchAppVersionSuccessed(let version):
            newState.appVersion = version
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .appVersion:
            return appVersionUseCase.execute()
                .map(Action.fetchAppVersionSuccessed)
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

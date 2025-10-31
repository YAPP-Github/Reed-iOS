// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine

final class NotificationSettingsViewModel: BaseViewModel {
    struct State: Equatable {
        var notificationEnabled: Bool = false
        var systemNotificationAuthorized: Bool = false
        var isLoading: Bool = false
        var error: DomainError? = nil
    }

    enum Action {
        case onAppear
        case systemNotificationAuthorizationChecked(Bool)
        case fetchNotificationSettingsSucceeded(Bool)
        case notificationToggleTapped(Bool)
        case updateNotificationSettingsSucceeded(Bool)
        case errorOccurred(DomainError)
        case errorHandled
    }

    enum SideEffect {
        case fetchNotificationSettings
        case updateNotificationSettings(Bool)
    }

    @Published private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()

    @Autowired private var authStateUseCase: AuthStateUseCase
    @Autowired private var updateNotificationSettingsUseCase: UpdateNotificationSettingsUseCase

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
            effects.append(.fetchNotificationSettings)

        case .systemNotificationAuthorizationChecked(let isAuthorized):
            newState.systemNotificationAuthorized = isAuthorized

        case .fetchNotificationSettingsSucceeded(let isEnabled):
            newState.notificationEnabled = isEnabled

        case .notificationToggleTapped(let isEnabled):
            newState.notificationEnabled = isEnabled
            newState.isLoading = true
            effects.append(.updateNotificationSettings(isEnabled))

        case .updateNotificationSettingsSucceeded(let isEnabled):
            newState.notificationEnabled = isEnabled
            newState.isLoading = false

        case .errorOccurred(let error):
            newState.isLoading = false
            newState.error = error
            /// 에러 발생시 이전 상태로 롤백
            effects.append(.fetchNotificationSettings)

        case .errorHandled:
            newState.error = nil
        }

        return (newState, effects)
    }

    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .fetchNotificationSettings:
            return authStateUseCase.execute()
                .map { userProfile in
                    Action.fetchNotificationSettingsSucceeded(userProfile.notificationEnabled)
                }
                .catch { error in
                    Just(Action.errorOccurred(DomainError.unauthorized))
                }
                .eraseToAnyPublisher()

        case .updateNotificationSettings(let isEnabled):
            return updateNotificationSettingsUseCase.execute(isEnabled: isEnabled)
                .map { updatedValue in
                    Action.updateNotificationSettingsSucceeded(updatedValue)
                }
                .catch { error in
                    Just(Action.errorOccurred(error))
                }
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

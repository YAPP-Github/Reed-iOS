// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

final class LoginViewModel: BaseViewModel {
    struct State {
        var isLoggedIn: Bool = false
        var alreadyAgree: Bool = false
        var latestProvider: String?
        var errorMessage: String?
    }
    
    enum Action {
        case appleLoginButtonTapped
        case kakaoLoginButtonTapped
        case loginAndTermsCheckSuccess(isAgreed: Bool)
        case authFailed(message: String)
    }
    
    enum SideEffect {
        case signInApple
        case signInKakao
    }
    
    @Published private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    @Autowired(name: "apple")
    private var appleLoginUseCase: SocialLoginUseCase
    @Autowired(name: "kakao")
    private var kakaoLoginUseCase: SocialLoginUseCase
    @Autowired private var socialTokenAuthUseCase: SocialTokenAuthUseCase
    @Autowired private var checkTermsStateUseCase: CheckTermsStateUseCase
    
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
    
    func reduce(
        action: Action,
        state: State
    ) -> (State, [SideEffect]) {
        var newState = state
        var effects: [SideEffect] = []
        
        switch action {
        case .appleLoginButtonTapped:
            newState.errorMessage = nil
            newState.latestProvider = "apple"
            effects.append(.signInApple)
            
        case .kakaoLoginButtonTapped:
            newState.errorMessage = nil
            newState.latestProvider = "kakao"
            effects.append(.signInKakao)
            
        case .loginAndTermsCheckSuccess(let isAgreed):
            newState.isLoggedIn = true
            newState.alreadyAgree = isAgreed
            newState.errorMessage = nil
            
        case .authFailed(let message):
            newState.errorMessage = message
        }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .signInApple:
            return appleLoginUseCase.execute()
                .flatMap { [weak self] token in
                    guard let self else { return Empty<Action, Never>().eraseToAnyPublisher() }
                    return self.socialTokenAuthUseCase.execute(
                        provider: .apple,
                        token: token
                    )
                    .flatMap { [weak self] _ -> AnyPublisher<Bool, AuthError>  in
                        guard let self else { return Empty<Bool, AuthError>().eraseToAnyPublisher() }
                        return self.checkTermsStateUseCase.execute()
                    }
                    .map { value in Action.loginAndTermsCheckSuccess(isAgreed: value) }
                    .catch { Just(Action.authFailed(message: $0.localizedDescription)) }
                    .eraseToAnyPublisher()
                }
                .catch { Just(Action.authFailed(message: $0.localizedDescription)) }
                .eraseToAnyPublisher()
            
        case .signInKakao:
            return kakaoLoginUseCase.execute()
                .flatMap { [weak self] token in
                    guard let self = self else { return Empty<Action, Never>().eraseToAnyPublisher() }
                    return self.socialTokenAuthUseCase.execute(
                        provider: .kakao,
                        token: token
                    )
                    .flatMap { [weak self] _ -> AnyPublisher<Bool, AuthError>  in
                        guard let self else { return Empty<Bool, AuthError>().eraseToAnyPublisher() }
                        return self.checkTermsStateUseCase.execute()
                    }
                    .map { value in Action.loginAndTermsCheckSuccess(isAgreed: value) }
                    .catch { Just(Action.authFailed(message: $0.localizedDescription)) }
                    .eraseToAnyPublisher()
                }
                .catch { Just(Action.authFailed(message: $0.localizedDescription)) }
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

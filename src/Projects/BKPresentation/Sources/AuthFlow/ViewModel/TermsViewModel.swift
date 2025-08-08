// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

final class TermsViewModel: BaseViewModel {
    
    // MARK: - Dependencies
    @Autowired private var termsAgreeUseCase: TermsAgreeUseCase
    
    // MARK: - Core Components
    struct State: Equatable {
        var terms: [Term] = []
        var isAllAgreed: Bool = false
        var isStartButtonEnabled: Bool = false
        var error: DomainError?
        var didAgreementSucceed: Bool = false
        var isLoading: Bool = false
    }
    
    enum Action {
        case viewDidLoad
        case agreeAllTapped
        case termTapped(index: Int)
        case startButtonTapped
        case agreementSuccess
        case agreementFailed(DomainError)
    }
    
    enum SideEffect {
        case agreeToTerms
    }
    
    // MARK: - Properties
    @Published private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let sideEffectSubject = PassthroughSubject<SideEffect, Never>()
    
    var statePublisher: AnyPublisher<State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    init() {
        bindSideEffects()
    }
    
    // MARK: - Methods
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
        
        newState.error = nil
        
        switch action {
        case .viewDidLoad:
            newState.terms = [
                Term(title: "(필수)서비스 이용약관", docsType: .terms, isRequired: true),
                Term(title: "(필수)개인정보처리방침", docsType: .privacy, isRequired: true),
                Term(title: "(필수)만 14세 이상입니다", isRequired: true)
            ]
            
        case .agreeAllTapped:
            let newAgreementState = !newState.isAllAgreed
            newState.isAllAgreed = newAgreementState
            
            for i in newState.terms.indices {
                newState.terms[i].isAgreed = newAgreementState
            }
            
        case .termTapped(let index):
            newState.terms[index].isAgreed.toggle()
            newState.isAllAgreed = newState.terms.allSatisfy { $0.isAgreed }
            
        case .startButtonTapped:
            guard state.isStartButtonEnabled else { break }
            newState.isLoading = true
            effects.append(.agreeToTerms)
            
        case .agreementSuccess:
            newState.didAgreementSucceed = true
            newState.isLoading = false
            
        case .agreementFailed(let error):
            newState.isLoading = false
            newState.error = error
        }
        
        newState.isStartButtonEnabled = newState.terms
            .filter { $0.isRequired }
            .allSatisfy { $0.isAgreed }
        
        return (newState, effects)
    }
    
    func handle(_ effect: SideEffect) -> AnyPublisher<Action, Never> {
        switch effect {
        case .agreeToTerms:
            return termsAgreeUseCase.execute(true)
                .map { isSuccess -> Action in
                    return isSuccess ? .agreementSuccess : .agreementFailed(.internalServerError)
                }
                .catch { error -> Just<Action> in
                    return Just(Action.agreementFailed(error))
                }
                .eraseToAnyPublisher()
        }
    }
    
    private func bindSideEffects() {
        sideEffectSubject
            .flatMap { [weak self] effect in
                self?.handle(effect) ?? Empty().eraseToAnyPublisher()
            }
            .sink(receiveValue: send)
            .store(in: &cancellables)
    }
}

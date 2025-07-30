// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultOnboardingCheckUseCase: OnboardingCheckUseCase {
    private let repository: OnboardingRepository
    
    public init(repository: OnboardingRepository) {
        self.repository = repository
    }
    
    public func execute() -> AnyPublisher<Bool, Never> {
        let result = repository.fetchOnboardingSeen()
        if !result {
            repository.saveOnboardingSeen()
        }
        return Just(result).eraseToAnyPublisher()
    }
}

// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct DefaultMarkOnboardingSeenUseCase: MarkOnboardingSeenUseCase {
    private let repository: OnboardingRepository
    
    public init(repository: OnboardingRepository) {
        self.repository = repository
    }
    
    public func execute() {
        repository.saveOnboardingSeen()
    }
    
    public func reset() {
        repository.resetOnboardingSeen()
    }
}

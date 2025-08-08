// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultFetchSeedStatsUseCase: FetchSeedStatsUseCase {
    private let repository: SeedRepository
    
    public init(repository: SeedRepository) {
        self.repository = repository
    }
    
    public func execute() -> AnyPublisher<[Seed], DomainError> {
        repository.stats()
    }
}

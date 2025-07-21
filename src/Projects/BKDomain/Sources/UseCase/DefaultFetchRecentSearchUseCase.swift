// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultFetchRecentSearchUseCase: FetchRecentSearchUseCase {
    private let repository: RecentSearchRepository
    
    public init(repository: RecentSearchRepository) {
        self.repository = repository
    }
    
    public func execute() -> AnyPublisher<[String], Never> {
        return Just(repository.load()).eraseToAnyPublisher()
    }
}

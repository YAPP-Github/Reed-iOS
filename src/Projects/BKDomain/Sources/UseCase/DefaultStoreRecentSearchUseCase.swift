// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultStoreRecentSearchUseCase: StoreRecentSearchUseCase {
    private let repository: RecentSearchRepository
    
    public init(repository: RecentSearchRepository) {
        self.repository = repository
    }
    
    public func execute(query: String) -> AnyPublisher<Void, Never> {
        return Just(repository.save(query: query)).eraseToAnyPublisher()
    }
}

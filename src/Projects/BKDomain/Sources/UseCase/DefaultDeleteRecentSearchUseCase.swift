// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultDeleteRecentSearchUseCase: DeleteRecentSearchUseCase {
    private let repository: RecentSearchRepository
    
    public init(repository: RecentSearchRepository) {
        self.repository = repository
    }
    
    public func execute(query: String) -> AnyPublisher<Void, Never> {
        return Just(repository.delete(query: query)).eraseToAnyPublisher()
    }
}

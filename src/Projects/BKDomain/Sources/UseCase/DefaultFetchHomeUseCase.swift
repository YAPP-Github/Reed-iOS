// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultFetchHomeUseCase: FetchHomeUseCase {
    private let repository: HomeRepository
    
    public init(repository: HomeRepository) {
        self.repository = repository
    }
    
    public func execute() -> AnyPublisher<[HomeInfo], Error> {
        repository.fetch()
            .eraseToAnyPublisher()
    }
}

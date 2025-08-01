// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultSearchBookUseCase: SearchBookUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(
        query: String,
        startIndex: Int
    ) -> AnyPublisher<(books: [Book], totalResults: Int), Never> {
        repository.search(
            SearchBookParameters(
                query: query,
                start: startIndex
            )
        )
        .map { ($0.0, $0.totalResults) }
        .eraseToAnyPublisher()
    }
}

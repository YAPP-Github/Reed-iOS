// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultBookUpsertUseCase: BookUpsertUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(
        isbn: String,
        status: BookStatus
    ) -> AnyPublisher<BookInfo, Error> {
        return repository.upsert(isbn, status)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

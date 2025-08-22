// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultDeleteBookUseCase: DeleteBookUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(
        bookId: String
    ) -> AnyPublisher<Void, DomainError> {
        repository.delete(bookId: bookId)
    }
}

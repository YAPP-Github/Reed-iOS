// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultFetchBookDetailUseCase: FetchBookDetailUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(isbn: String) -> AnyPublisher<Book, Error> {
        repository.detail(isbn: isbn)
    }
}

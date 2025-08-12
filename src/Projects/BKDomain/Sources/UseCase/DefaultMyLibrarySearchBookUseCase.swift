// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultMyLibrarySearchBookUseCase: MyLibrarySearchBookUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(
        query: String? = nil,
        startIndex: Int? = nil
    ) -> AnyPublisher<(books: [BookInfo], totalResults: Int), DomainError> {
        repository.searchMyLibrary(
            MyLibraryParameters(
                pageNumber: startIndex,
                title: query
            )
        )
        .map { ($0.0, $0.totalElements) }
        .eraseToAnyPublisher()
    }
}

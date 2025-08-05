// Copyright © 2025 Booket. All rights reserved

import Combine

public struct LibrarySearchBookUseCase: SearchBookUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(
        query: String,
        startIndex: Int
    ) -> AnyPublisher<(books: [Book], totalResults: Int), Never> {
        repository.searchMyLibrary(
            MyLibraryParameters(
                pageNumber: startIndex,
                title: query
            )
        )
        .map { ($0.0, $0.totalResults) }
        .eraseToAnyPublisher()
    }
}

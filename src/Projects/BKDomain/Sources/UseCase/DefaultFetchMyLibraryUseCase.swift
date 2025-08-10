// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultFetchMyLibraryUseCase: FetchMyLibraryUseCase {
    private let repository: BookRepository
    
    public init(repository: BookRepository) {
        self.repository = repository
    }
    
    public func execute(
        query: String?,
        startIndex: Int?,
        status: BookStatus?
    ) -> AnyPublisher<(books: [BookInfo], bookCountSet: BookCountSet), DomainError> {
        repository.searchMyLibrary(
            MyLibraryParameters(
                status: status,
                pageNumber: startIndex,
                title: query
            )
        )
        .map { ($0.0, $0.bookCountSet) }
        .eraseToAnyPublisher()
    }
}

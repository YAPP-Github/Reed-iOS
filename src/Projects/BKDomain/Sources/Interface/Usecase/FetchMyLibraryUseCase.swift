// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol FetchMyLibraryUseCase {
    func execute(
        query: String?,
        startIndex: Int?,
        status: BookStatus?
    ) -> AnyPublisher<(books: [BookInfo], totalResults: BookCountSet), DomainError>
}

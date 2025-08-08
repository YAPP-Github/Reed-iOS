// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol MyLibrarySearchBookUseCase {
    func execute(
        query: String?,
        startIndex: Int?
    ) -> AnyPublisher<(books: [BookInfo], totalResults: Int), DomainError>
}

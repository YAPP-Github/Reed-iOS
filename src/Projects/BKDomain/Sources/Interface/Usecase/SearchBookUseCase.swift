// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol SearchBookUseCase {
    func execute(
        query: String,
        startIndex: Int
    ) -> AnyPublisher<(books: [Book], totalResults: Int), Never>
}

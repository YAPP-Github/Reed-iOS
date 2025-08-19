// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol SearchBookUseCase {
    func execute(
        query: String?,
        startIndex: Int?,
        isGuestMode: Bool
    ) -> AnyPublisher<(books: [Book], totalResults: Int), DomainError>
}

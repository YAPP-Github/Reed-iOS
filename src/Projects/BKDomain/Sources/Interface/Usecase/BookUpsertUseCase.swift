// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol BookUpsertUseCase {
    func execute(
        isbn: String,
        status: BookStatus
    ) -> AnyPublisher<BookInfo, DomainError>
}

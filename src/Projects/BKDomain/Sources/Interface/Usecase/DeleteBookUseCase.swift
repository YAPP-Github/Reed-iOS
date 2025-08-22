// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol DeleteBookUseCase {
    func execute(
        bookId: String
    ) -> AnyPublisher<Void, DomainError>
}

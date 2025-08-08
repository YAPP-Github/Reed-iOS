// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol FetchBookDetailUseCase {
    func execute(isbn: String) -> AnyPublisher<Book, DomainError>
}

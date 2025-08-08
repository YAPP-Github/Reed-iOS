// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol FetchHomeUseCase {
    func execute() -> AnyPublisher<[HomeInfo], DomainError>
}

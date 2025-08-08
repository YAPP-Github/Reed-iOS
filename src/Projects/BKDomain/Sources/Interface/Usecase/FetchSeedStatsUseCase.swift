// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol FetchSeedStatsUseCase {
    func execute() -> AnyPublisher<[Seed], DomainError>
}

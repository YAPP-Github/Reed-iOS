// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol FetchSeedStatsUseCase {
    func execute(
        id recordId: String
    ) -> AnyPublisher<[Seed], DomainError>
}

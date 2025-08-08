// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol SeedRepository {
    func stats(
        id recordId: String
    ) -> AnyPublisher<[Seed], DomainError>
}

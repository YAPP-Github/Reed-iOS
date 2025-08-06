// Copyright © 2025 Booket. All rights reserved

import Combine
import BKCore
import BKDomain

public struct DefaultSeedRepository: SeedRepository {
    let networkProvider: NetworkProvider
    
    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }
    
    public func stats() -> AnyPublisher<[Seed], Error> {
        networkProvider.request(
            target: SeedAPI.stats,
            type: SeedStatsResponseDTO.self
        )
        .mapError { $0 as Error }
        .debugError(logger: AppLogger.network)
        .map { $0.categories }
        .eraseToAnyPublisher()
    }
}

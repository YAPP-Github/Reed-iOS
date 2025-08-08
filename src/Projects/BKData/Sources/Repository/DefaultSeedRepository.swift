// Copyright © 2025 Booket. All rights reserved

import Combine
import BKCore
import BKDomain

public struct DefaultSeedRepository: SeedRepository {
    let networkProvider: NetworkProvider
    
    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }
    
    public func stats(
        id recordId: String
    ) -> AnyPublisher<[Seed], DomainError> {
        networkProvider.request(
            target: RecordAPI.seed(userRecordId: recordId),
            type: SeedStatsResponseDTO.self
        )
        .mapError { $0.toDomainError() }
        .debugError(logger: AppLogger.network)
        .map { $0.categories }
        .eraseToAnyPublisher()
    }
}

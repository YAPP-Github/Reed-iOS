// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine

public struct DefaultHomeRepository: HomeRepository {
    let networkProvider: NetworkProvider
    
    public func fetch() -> AnyPublisher<[HomeInfo], Error> {
        networkProvider.request(
            target: HomeAPI.fetch,
            type: FetchHomeResponseDTO.self
        )
        .mapError { $0 as Error }
        .map { $0.recentBooks.map { $0.toEntity() }}
        .eraseToAnyPublisher()
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

public struct DefaultAppStoreRepository: AppStoreRepository {
    private let networkProvider: NetworkProvider
    
    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }
    
    public func fetchAppStoreVersion() -> AnyPublisher<String, Error> {
        return networkProvider.request(
            target: AppstoreAPI.lookup(appId: "6747740414"),
            type: AppStoreResponseDTO.self
        )
        .debugError(logger: AppLogger.network)
        .tryMap { response in
            guard let firstResult = response.results.first else {
                throw URLError(.cannotParseResponse)
            }
            return firstResult.version
        }
        .eraseToAnyPublisher()
    }
}

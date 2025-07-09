// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import Combine
import Foundation

public struct AuthRetrier {
    private let refreshHandler: (_ token: String) -> AnyPublisher<Void, NetworkError>
    private let tokenProvider: TokenProvider
    
    public init(
        refreshHandler: @escaping (_ token: String) -> AnyPublisher<Void, NetworkError>,
        tokenProvider: TokenProvider
    ) {
        self.refreshHandler = refreshHandler
        self.tokenProvider = tokenProvider
    }
    
    func retryIfNeeded(
        _ response: URLResponse,
        _ data: Data
    ) -> AnyPublisher<Void, NetworkError> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return Fail(error: .invalidResponse)
                .eraseToAnyPublisher()
        }
        
        guard httpResponse.statusCode == 401 else {
            return Fail(error: .retryFailed)
                .eraseToAnyPublisher()
        }

        guard let accessToken = tokenProvider.accessToken else {
            return Fail(error: .retryFailed)
                .eraseToAnyPublisher()
        }

        Log.debug("[Refresh] AccessToken: \(accessToken)", logger: AppLogger.auth)
        return refreshHandler(accessToken)
    }
}

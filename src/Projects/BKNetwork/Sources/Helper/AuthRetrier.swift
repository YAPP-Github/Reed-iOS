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
        guard shouldRetry(response: response) else {
            return Just(())
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }

        return performRefresh()
    }
}

private extension AuthRetrier {
    func shouldRetry(response: URLResponse) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }
        return httpResponse.statusCode == 401
    }
    
    func performRefresh() -> AnyPublisher<Void, NetworkError> {
        guard let refreshToken = tokenProvider.refreshToken else {
            return Fail(error: .retryFailed).eraseToAnyPublisher()
        }

        Log.debug("[Refresh] RefreshToken: \(refreshToken.prefix(10))", logger: AppLogger.auth)
        return refreshHandler(refreshToken)
    }
}

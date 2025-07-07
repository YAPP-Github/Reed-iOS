// Copyright © 2025 Booket. All rights reserved

import BKData
import Foundation

public struct AuthInterceptor {
    private let tokenProvider: TokenProvider
    
    public init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func adapt(_ request: URLRequest) -> URLRequest {
        guard let token = tokenProvider.accessToken else { return request }
        
        var adapted = request
        adapted.addAuthorization(token)
        return adapted
    }
    
    func retryIfNeeded(
        _ response: URLResponse,
        _ data: Data
    ) throws {
        let httpResponse = try response.asHTTP
            .orThrow(NetworkError.invalidResponse)
        if httpResponse.statusCode == 401 {
            tokenProvider.refreshIfNeeded()
            throw RetryTrigger()
        }
    }
}

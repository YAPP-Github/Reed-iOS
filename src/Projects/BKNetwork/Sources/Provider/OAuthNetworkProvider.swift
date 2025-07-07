// Copyright © 2025 Booket. All rights reserved

import BKData
import Combine
import Foundation

public struct OAuthNetworkProvider: NetworkProvider {
    private let requestor: NetworkRequestable
    private let interceptor: AuthInterceptor
    
    public init(requestor: NetworkRequestable, interceptor: AuthInterceptor) {
        self.requestor = requestor
        self.interceptor = interceptor
    }
    
    @discardableResult
    public func request<T: Decodable>(
        target: RequestTarget,
        type: T.Type
    ) -> AnyPublisher<T, Error> {
        do {
            let adaptedRequest = try interceptor.adapt(target.makeURLRequest())
            return requestor.data(for: adaptedRequest)
                .tryMap { data, response in
                    try response.asHTTP
                        .orThrow(NetworkError.internalServerError)
                        .validate(data)
                    try interceptor.retryIfNeeded(response, data)
                    return try data.decode(to: type)
                }
                .retryIf({ $0 is RetryTrigger }, maxRetries: 1)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}

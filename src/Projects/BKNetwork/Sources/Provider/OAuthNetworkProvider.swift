// Copyright © 2025 Booket. All rights reserved

import BKCore
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
    ) -> AnyPublisher<T, NetworkError> {
        return target.makeURLRequest()
            .flatMap { request in
                let adaptedRequest = interceptor.adapt(request)
                return requestor.data(for: adaptedRequest)
                    .tryMap { data, response in
                        try interceptor.retryIfNeeded(response, data)
                        try response.asHTTP
                            .orThrow(NetworkError.invalidResponse)
                            .validate(data)
                        return try data.decode(to: type)
                    }
                    .mapError { $0 as? NetworkError ?? .invalidResponse }
            }
            .retryIf({ $0 == NetworkError.retryTrigger }, maxRetries: 1)
            .eraseToAnyPublisher()
    }
}

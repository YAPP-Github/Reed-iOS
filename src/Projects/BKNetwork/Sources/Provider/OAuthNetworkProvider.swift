// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import Combine
import Foundation

public struct OAuthNetworkProvider: NetworkProvider {
    private let requestor: NetworkRequestable
    private let interceptor: AuthInterceptor
    private let authRetrier: AuthRetrier
    
    public init(
        requestor: NetworkRequestable,
        interceptor: AuthInterceptor,
        authRetrier: AuthRetrier
    ) {
        self.requestor = requestor
        self.interceptor = interceptor
        self.authRetrier = authRetrier
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
                    .mapError { $0 as? NetworkError ?? .invalidResponse }
                    .flatMap { data, response in
                        self.handleRetryIfNeeded(data: data, response: response)
                    }
                    .tryMap { data, response in
                        let httpResponse = try response.asHTTP
                            .orThrow(NetworkError.invalidResponse)
                        
                        if httpResponse.statusCode == 204 {
                            if let empty = EmptyResponse() as? T {
                                return empty
                            } else {
                                throw NetworkError.invalidResponse
                            }
                        }
                        try httpResponse.validate(data)
                        
                        return try data.decode(to: type)
                    }
                    .debugError("Decoding Failed", logger: AppLogger.network)
                    .mapError { $0 as? NetworkError ?? .invalidResponse }
            }
            .eraseToAnyPublisher()
    }
}

private extension OAuthNetworkProvider {
    func handleRetryIfNeeded(
        data: Data,
        response: URLResponse
    ) -> AnyPublisher<(Data, URLResponse), NetworkError> {
        authRetrier.retryIfNeeded(response, data)
            .catch { error -> AnyPublisher<Void, NetworkError> in
                if case .retryFailed = error {
                    return Just(()).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .map { (data, response) }
            .map { _ in (data, response) }
            .eraseToAnyPublisher()
    }
}

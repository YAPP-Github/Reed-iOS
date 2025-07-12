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
        makeRequest(target: target)
            .flatMap(handleRetryIfNeeded)
            .tryMap { data, response in
                try self.decodeResponse(data: data, response: response, type: type)
            }
            .debugError("Decoding Failed", logger: AppLogger.network)
            .mapError { $0 as? NetworkError ?? .invalidResponse }
            .retryIf({ $0 == .retryTrigger }, maxRetries: 1)
            .eraseToAnyPublisher()
    }
}

private extension OAuthNetworkProvider {
    func makeRequest(
        target: RequestTarget
    ) -> AnyPublisher<(Data, URLResponse), NetworkError> {
        target.makeURLRequest()
            .flatMap { request in
                let adapted = self.interceptor.adapt(request)
                return self.requestor.data(for: adapted)
                    .mapError { $0 as? NetworkError ?? .invalidResponse }
            }
            .eraseToAnyPublisher()
    }
    
    func decodeResponse<T: Decodable>(
        data: Data,
        response: URLResponse,
        type: T.Type
    ) throws -> T {
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
    
    func handleRetryIfNeeded(
        data: Data,
        response: URLResponse
    ) -> AnyPublisher<(Data, URLResponse), NetworkError> {
        authRetrier.retryIfNeeded(response, data)
            .catch { error -> AnyPublisher<Void, NetworkError> in
                switch error {
                case .retryFailed, .retryTrigger:
                    return Just(()).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
                default:
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .map { (data, response) }
            .eraseToAnyPublisher()
    }
}

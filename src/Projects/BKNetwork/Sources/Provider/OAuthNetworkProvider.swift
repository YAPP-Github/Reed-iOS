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
        return requestWithRetry(target: target)
            .tryMap { data, response in
                try self.decodeResponse(data: data, response: response, type: type)
            }
            .debugError("Decoding Failed", logger: AppLogger.network)
            .mapError { self.mapToNetworkError($0) }
            .eraseToAnyPublisher()
    }
}

private extension OAuthNetworkProvider {
    func requestWithRetry(
        target: RequestTarget
    ) -> AnyPublisher<(Data, URLResponse), NetworkError> {
        makeRequest(target: target)
            .flatMap { data, response in
                self.retryIfNeeded(
                    target: target,
                    data: data,
                    response: response
                )
            }
            .eraseToAnyPublisher()
    }
    
    func retryIfNeeded(
        target: RequestTarget,
        data: Data,
        response: URLResponse
    ) -> AnyPublisher<(Data, URLResponse), NetworkError> {
        guard let http = response as? HTTPURLResponse,
              http.statusCode == 401
        else {
            return Just((data, response))
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        return authRetrier.performRefresh()
            .flatMap { _ in
                self.makeRequest(target: target)
            }
            .eraseToAnyPublisher()
    }
    
    func makeRequest(
        target: RequestTarget
    ) -> AnyPublisher<(Data, URLResponse), NetworkError> {
        target.makeURLRequest()
            .flatMap { request in
                let adapted = self.interceptor.adapt(request)
                return self.requestor.data(for: adapted)
                    .mapError { self.mapToNetworkError($0) }
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
}

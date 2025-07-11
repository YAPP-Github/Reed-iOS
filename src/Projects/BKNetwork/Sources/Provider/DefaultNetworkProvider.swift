// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import Combine
import Foundation
import OSLog

public struct DefaultNetworkProvider: NetworkProvider {
    private let requestor: NetworkRequestable
    
    public init(requestor: NetworkRequestable) {
        self.requestor = requestor
    }
    
    @discardableResult
    public func request<T: Decodable>(
        target: RequestTarget,
        type: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        makeRequest(target: target)
            .tryMap { data, response in
                try self.decodeResponse(data: data, response: response, type: type)
            }
            .debugError("Decoding Failed", logger: AppLogger.network)
            .mapError { $0 as? NetworkError ?? .invalidResponse }
            .eraseToAnyPublisher()
    }
}

private extension DefaultNetworkProvider {
    func makeRequest(
        target: RequestTarget
    ) -> AnyPublisher<(Data, URLResponse), NetworkError> {
        target.makeURLRequest()
            .flatMap { request in
                self.requestor.data(for: request)
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
}

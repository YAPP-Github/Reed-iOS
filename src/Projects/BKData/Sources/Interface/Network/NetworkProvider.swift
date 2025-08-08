// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

public protocol NetworkProvider {
    @discardableResult
    func request<T: Decodable>(
        target: RequestTarget,
        type: T.Type
    ) -> AnyPublisher<T, NetworkError>
}

public extension NetworkProvider {
    func mapToNetworkError(_ error: Error) -> NetworkError {
        if let net = error as? NetworkError { return net }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut,
                 .networkConnectionLost,
                 .cannotFindHost,
                 .cannotConnectToHost,
                 .dnsLookupFailed,
                 .notConnectedToInternet:
                return .timeout
            default:
                return .unknown
            }
        }
        return .unknown
    }
}

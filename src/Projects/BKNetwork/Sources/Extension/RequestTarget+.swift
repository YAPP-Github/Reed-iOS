// Copyright © 2025 Booket. All rights reserved

import BKData
import Combine
import Foundation

extension RequestTarget {
    var query: [String: Any] {
        return [:]
    }
    
    func makeURLRequest() -> AnyPublisher<URLRequest, NetworkError> {
        Just(())
            .setFailureType(to: NetworkError.self)
            .tryMap { _ in
                var request = try URLRequest(baseURL + path, query: query)
                request.makeURLHeaders(headers)
                request.httpMethod = method.rawValue
                request.cachePolicy = .reloadIgnoringLocalCacheData
                if let body { request.setBody(body) }
                return request
            }
            .mapError { error in error as? NetworkError ?? NetworkError.invalidURL }
            .eraseToAnyPublisher()
    }
}

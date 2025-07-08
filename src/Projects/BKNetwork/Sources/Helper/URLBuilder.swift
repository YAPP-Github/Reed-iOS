// Copyright © 2025 Booket. All rights reserved

import BKData
import Combine
import Foundation

public struct URLBuilder: URLBuilding {
    public func makeURL(target: RequestTarget) -> AnyPublisher<URL, NetworkError> {
        return target
            .makeURLRequest()
            .tryMap { request in
                guard let url = request.url else {
                    throw NetworkError.invalidURL
                }
                return url
            }
            .mapError { $0 as? NetworkError ?? .invalidURL }
            .eraseToAnyPublisher()
    }
}

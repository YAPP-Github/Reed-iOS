// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

extension URLSessionConfiguration {
    static let bkDefault: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = false
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        return config
    }()
}

final class URLSessionRequestor: NetworkRequestable {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    convenience init(configuration: URLSessionConfiguration = .bkDefault) {
        self.init(session: URLSession(configuration: configuration))
    }

    func data(for request: URLRequest) -> AnyPublisher<(Data, URLResponse), Error> {
        session.dataTaskPublisher(for: request)
            .map { ($0.data, $0.response) }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

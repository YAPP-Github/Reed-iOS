// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol NetworkProvider {
    @discardableResult
    func request<T: Decodable>(
        target: RequestTarget,
        type: T.Type
    ) -> AnyPublisher<T, NetworkError>
}

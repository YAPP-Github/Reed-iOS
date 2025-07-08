// Copyright © 2025 Booket. All rights reserved

import BKData
import Combine

extension Publisher where Failure == NetworkError {
    func retryIf(
        _ shouldRetry: @escaping (Failure) -> Bool,
        maxRetries: Int
    ) -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            guard maxRetries > 0, shouldRetry(error) else {
                return Fail(error: error).eraseToAnyPublisher()
            }
            return self
                .retryIf(shouldRetry, maxRetries: maxRetries - 1)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

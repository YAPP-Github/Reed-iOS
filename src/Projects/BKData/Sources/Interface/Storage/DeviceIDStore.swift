// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine

public protocol DeviceIDStore {
    func getOrCreate() -> AnyPublisher<String, TokenError>
    func clear() -> AnyPublisher<Void, TokenError>
}

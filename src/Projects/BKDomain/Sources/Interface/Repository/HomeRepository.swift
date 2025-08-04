// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol HomeRepository {
    func fetch() -> AnyPublisher<[HomeInfo], Error>
}

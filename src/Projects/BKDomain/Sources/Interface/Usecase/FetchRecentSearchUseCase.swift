// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol FetchRecentSearchUseCase {
    func execute() -> AnyPublisher<[String], Never>
}

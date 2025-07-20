// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol DeleteRecentSearchUseCase {
    func execute(query: String) -> AnyPublisher<Void, Never>
}

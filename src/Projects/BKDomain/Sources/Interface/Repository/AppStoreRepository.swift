// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol AppStoreRepository {
    func fetchAppStoreVersion() -> AnyPublisher<String, Error>
}

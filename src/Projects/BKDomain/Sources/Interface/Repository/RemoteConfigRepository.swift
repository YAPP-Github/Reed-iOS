// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

public protocol RemoteConfigRepository {
    func fetchRemoteAppVersions() -> AnyPublisher<RemoteAppVersion, Error>
}

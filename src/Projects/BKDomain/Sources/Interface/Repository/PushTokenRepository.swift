// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol PushTokenRepository {
    func getFCMToken() -> String?
    func isSyncNeeded() -> Bool
    func resetSyncNeeded() -> AnyPublisher<Void, DomainError>
    func clearCache()
}

// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine

public protocol PushTokenStore {
    func save(
        fcmToken: String
    ) -> AnyPublisher<Void, TokenError>

    func resetSyncNeeded() -> AnyPublisher<Void, TokenError>

    func clear() -> AnyPublisher<Void, TokenError>
}

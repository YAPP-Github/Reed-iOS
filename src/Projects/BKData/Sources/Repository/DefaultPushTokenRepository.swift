// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine

public struct DefaultPushTokenRepository: PushTokenRepository {
    private let pushTokenProvider: PushTokenProvider
    private let pushTokenStore: PushTokenStore

    public init(
        pushTokenProvider: PushTokenProvider,
        pushTokenStore: PushTokenStore
    ) {
        self.pushTokenProvider = pushTokenProvider
        self.pushTokenStore = pushTokenStore
    }

    public func getFCMToken() -> String? {
        return pushTokenProvider.fcmToken
    }

    public func isSyncNeeded() -> Bool {
        return pushTokenProvider.isSyncNeeded ?? false
    }

    public func resetSyncNeeded() -> AnyPublisher<Void, DomainError> {
        return pushTokenStore
            .resetSyncNeeded()
            .map { _ in
                self.pushTokenProvider.clearCache()
            }
            .mapError { error in
                Log.error("Failed to reset isSyncNeeded flag: \(error)", logger: AppLogger.storage)
                return .clientError
            }
            .eraseToAnyPublisher()
    }

    public func clearCache() {
        pushTokenProvider.clearCache()
    }
}

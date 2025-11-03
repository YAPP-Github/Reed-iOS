// Copyright © 2025 Booket. All rights reserved

import Combine
import BKData

public struct KeychainPushTokenStore: PushTokenStore {
    private let storage: KeyValueStorage

    /// AppDelegate에서 DI 없이 사용할 수 있도록 shared instance 제공
    public static let shared = KeychainPushTokenStore(storage: KeychainKeyValueStorage())

    public init(storage: KeyValueStorage) {
        self.storage = storage
    }

    /// FCM Token을 저장하는 시점에서, 서버와의 동기화 여부를 확인합니다.
    /// 발급된 FCM Token이 Storage와 다른 경우에만 isSyncNeededKey를 true로 변경하고, 이는 Upsert의 트리거가 됩니다.
    public func save(fcmToken: String) -> AnyPublisher<Void, TokenError> {
        do {
            let existingToken: String? = try? storage.load(for: StorageKeys.fcmTokenKey)
            let isTokenChanged = existingToken != fcmToken
            try storage.save(fcmToken, for: StorageKeys.fcmTokenKey)
            if isTokenChanged {
                try storage.save(true, for: StorageKeys.isSyncNeededKey)
            }

            return Just(())
                .setFailureType(to: TokenError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: TokenError.saveFailed(underlying: error))
                .eraseToAnyPublisher()
        }
    }

    public func resetSyncNeeded() -> AnyPublisher<Void, TokenError> {
        do {
            try storage.save(false, for: StorageKeys.isSyncNeededKey)
            return Just(())
                .setFailureType(to: TokenError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: TokenError.saveFailed(underlying: error))
                .eraseToAnyPublisher()
        }
    }

    public func clear() -> AnyPublisher<Void, TokenError> {
        do {
            try storage.delete(for: StorageKeys.fcmTokenKey)
            try storage.delete(for: StorageKeys.isSyncNeededKey)
            return Just(())
                .setFailureType(to: TokenError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: TokenError.clearFailed(underlying: error))
                .eraseToAnyPublisher()
        }
    }
}

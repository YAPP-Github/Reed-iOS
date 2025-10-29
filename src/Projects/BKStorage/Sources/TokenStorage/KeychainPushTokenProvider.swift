// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import OSLog

public final class KeychainPushTokenProvider: PushTokenProvider {
    private let storage: KeyValueStorage
    private var cachedFCMToken: String?
    private var cachedIsSyncNeeded: Bool?

    public init(storage: KeyValueStorage) {
        self.storage = storage
    }

    public var fcmToken: String? {
        if let cachedFCMToken {
            return cachedFCMToken
        }
        do {
            let token: String = try storage.load(for: StorageKeys.fcmTokenKey)
            self.cachedFCMToken = token
            return token
        } catch {
            Log.error("Failed to load fcmToken: \(error)", logger: AppLogger.storage)
            return nil
        }
    }

    public var isSyncNeeded: Bool? {
        if let cachedIsSyncNeeded {
            return cachedIsSyncNeeded
        }
        do {
            let flag: Bool = try storage.load(for: StorageKeys.isSyncNeededKey)
            self.cachedIsSyncNeeded = flag
            return flag
        } catch {
            Log.error("Failed to load isSyncNeeded: \(error)", logger: AppLogger.storage)
            return nil
        }
    }

    public func clearCache() {
        cachedFCMToken = nil
        cachedIsSyncNeeded = nil
    }
}

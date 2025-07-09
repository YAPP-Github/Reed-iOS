// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import OSLog

public final class KeychainTokenProvider: TokenProvider {
    private let storage: KeyValueStorage
    private var cachedAccessToken: String?
    
    public init(storage: KeyValueStorage) {
        self.storage = storage
    }
    public var accessToken: String? {
        if let cachedAccessToken {
            return cachedAccessToken
        }
        do {
            let token: String = try storage.load(for: StorageKeys.accessTokenKey)
            self.cachedAccessToken = token
            return token
        } catch {
            Log.error("Failed to load accessToken: \(error)", logger: AppLogger.storage)
            return nil
        }
    }
    
    public func clearCache() {
        cachedAccessToken = nil
    }
}

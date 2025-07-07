// Copyright © 2025 Booket. All rights reserved

import BKData
import Combine
import Foundation

public struct KeychainTokenStore: TokenStore {
    private let storage: KeyValueStorage
    
    public init(storage: KeyValueStorage) {
        self.storage = storage
    }
    
    public func save(
        accessToken: String,
        refreshToken: String
    ) -> AnyPublisher<Void, TokenError> {
        do {
            try storage.save(accessToken, for: StorageKeys.accessTokenKey)
            try storage.save(refreshToken, for: StorageKeys.refreshTokenKey)
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
            try storage.delete(for: StorageKeys.accessTokenKey)
            try storage.delete(for: StorageKeys.refreshTokenKey)
            return Just(())
                .setFailureType(to: TokenError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: TokenError.clearFailed(underlying: error))
                .eraseToAnyPublisher()
        }
    }
}

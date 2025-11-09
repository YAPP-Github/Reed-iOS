// Copyright © 2025 Booket. All rights reserved

import BKData
import BKDomain
import Combine
import Foundation

public struct KeychainDeviceIDStore: DeviceIDStore {
    private let storage: KeyValueStorage
    
    /// AppDelegate나 다른 곳에서 DI 없이 사용할 수 있도록 shared instance 제공
    public static let shared = KeychainDeviceIDStore(storage: KeychainKeyValueStorage())

    public init(storage: KeyValueStorage) {
        self.storage = storage
    }
    
    /// 디바이스 ID를 가져오거나, 없으면 새로 생성하여 저장
    /// 키체인에 저장되므로 앱 삭제 후 재설치해도 유지됨
    public func getOrCreate() -> AnyPublisher<String, TokenError> {
        do {
            if let existingID: String = try? storage.load(for: StorageKeys.deviceIDKey) {
                return Just(existingID)
                    .setFailureType(to: TokenError.self)
                    .eraseToAnyPublisher()
            }
            
            let newDeviceID = UUID().uuidString
            try storage.save(newDeviceID, for: StorageKeys.deviceIDKey)

            return Just(newDeviceID)
                .setFailureType(to: TokenError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: TokenError.saveFailed(underlying: error))
                .eraseToAnyPublisher()
        }
    }
    
    public func clear() -> AnyPublisher<Void, TokenError> {
        do {
            try storage.delete(for: StorageKeys.deviceIDKey)
            return Just(())
                .setFailureType(to: TokenError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: TokenError.clearFailed(underlying: error))
                .eraseToAnyPublisher()
        }
    }
}

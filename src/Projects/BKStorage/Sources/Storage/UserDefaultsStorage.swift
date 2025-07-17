// Copyright © 2025 Booket. All rights reserved

import BKData
import Foundation

public struct UserDefaultsStorage: KeyValueStorage {
    private let userDefaults: UserDefaults

    public init() {
        self.userDefaults = .standard
    }

    public func save<T: Encodable>(_ data: T, for account: String) throws {
        let encoded = try JSONEncoder().encode(data)
        userDefaults.set(encoded, forKey: account)
    }

    public func load<T: Decodable>(for account: String) throws -> T {
        guard let data = userDefaults.data(forKey: account) else {
            throw StorageError.notFound
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    public func delete(for account: String) throws {
        userDefaults.removeObject(forKey: account)
    }
}

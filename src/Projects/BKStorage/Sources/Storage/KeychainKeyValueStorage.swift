// Copyright © 2025 Booket. All rights reserved

import BKData
import Foundation
import Security

public struct KeychainKeyValueStorage: KeyValueStorage {
    public init() {}
    
    public func save<T>(_ data: T, for account: String) throws where T: Encodable {
        let jsonData = try encode(data)
        let query = baseQuery(for: account)

        let exists = (SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess)

        let status: OSStatus
        if exists {
            let attributes = [kSecValueData as String: jsonData]
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        } else {
            var addQuery = query
            addQuery[kSecValueData as String] = jsonData
            status = SecItemAdd(addQuery as CFDictionary, nil)
        }

        if status != errSecSuccess { throw StorageError.writeError }
    }
    
    public func load<T>(for account: String) throws -> T where T: Decodable {
        let query = baseQuery(for: account).merging([
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]) { $1 }

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound { throw StorageError.notFound }
        guard status == errSecSuccess,
              let data = result as? Data else {
            throw StorageError.readError
        }

        return try decode(data)
    }
    
    public func delete(for account: String) throws {
        let query = baseQuery(for: account)
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw StorageError.deleteError
        }
    }
}

private extension KeychainKeyValueStorage {
    private func baseQuery(for account: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: "Booket.26th.yapp"
        ]
    }

    private func encode<T: Encodable>(_ data: T) throws -> Data {
        if let string = data as? String {
            return Data(string.utf8)
        } else if let rawData = data as? Data {
            return rawData
        } else {
            return try JSONEncoder().encode(data)
        }
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self == String.self, let string = String(data: data, encoding: .utf8) as? T {
            return string
        } else {
            return try JSONDecoder().decode(T.self, from: data)
        }
    }
}

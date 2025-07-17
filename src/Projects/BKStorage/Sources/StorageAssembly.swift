// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import Foundation

public struct StorageAssembly: Assembly {
    public init() {}
    
    public func assemble(container: DIContainer) {
        container.register(
            type: KeyValueStorage.self,
            name: "Keychain"
        ) { _ in
            return KeychainKeyValueStorage()
        }
        
        container.register(
            type: KeyValueStorage.self,
            name: "UserDefaults"
        ) { _ in
            return UserDefaultsStorage()
        }
        
        container.register(
            type: TokenProvider.self,
            scope: .singleton
        ) { _ in
            @Autowired(name: "Keychain") var keyValueStorage: KeyValueStorage
            return KeychainTokenProvider(
                storage: keyValueStorage
            )
        }
        
        container.register(
            type: TokenStore.self
        ) { _ in
            @Autowired(name: "Keychain") var keyValueStorage: KeyValueStorage
            return KeychainTokenStore(
                storage: keyValueStorage
            )
        }
    }
}

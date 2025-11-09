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

        container.register(
            type: PushTokenProvider.self,
            scope: .singleton
        ) { _ in
            @Autowired(name: "Keychain") var keyValueStorage: KeyValueStorage
            return KeychainPushTokenProvider(
                storage: keyValueStorage
            )
        }

        container.register(
            type: PushTokenStore.self
        ) { _ in
            @Autowired(name: "Keychain") var keyValueStorage: KeyValueStorage
            return KeychainPushTokenStore(
                storage: keyValueStorage
            )
        }
        
        container.register(
            type: DeviceIDProvider.self,
            scope: .singleton
        ) { _ in
            @Autowired(name: "Keychain") var keyValueStorage: KeyValueStorage
            return KeychainDeviceIDProvider(
                storage: keyValueStorage
            )
        }
        
        container.register(
            type: DeviceIDStore.self
        ) { _ in
            @Autowired(name: "Keychain") var keyValueStorage: KeyValueStorage
            return KeychainDeviceIDStore(
                storage: keyValueStorage
            )
        }
    }
}

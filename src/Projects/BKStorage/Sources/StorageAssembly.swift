// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import Foundation

public struct StorageAssembly: Assembly {
    public init() {}
    
    public func assemble(container: DIContainer) {
        container.register(
            type: KeyValueStorage.self
        ) { _ in
            return KeychainKeyValueStorage()
        }
        
        container.register(
            type: TokenProvider.self,
            scope: .singleton
        ) { _ in
            @Autowired var keyValueStorage: KeyValueStorage
            return KeychainTokenProvider(
                storage: keyValueStorage
            )
        }
        
        container.register(
            type: TokenStore.self
        ) { _ in
            @Autowired var keyValueStorage: KeyValueStorage
            return KeychainTokenStore(
                storage: keyValueStorage
            )
        }
    }
}

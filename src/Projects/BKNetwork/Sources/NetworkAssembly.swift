// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import Foundation

public struct NetworkAssembly: Assembly {
    public init() {}
    
    public func assemble(container: DIContainer) {
        container.register(
            type: NetworkProvider.self,
            name: "default"
        ) { _ in
            return DefaultNetworkProvider(
                requestor: URLSessionRequestor()
            )
        }
        
        container.register(
            type: NetworkProvider.self,
            name: "oauth"
        ) { _ in
            // TODO: - TokenProvider <-> AuthInterceptor 순환 참조 해결
            @Autowired var tokenProvider: TokenProvider
            return OAuthNetworkProvider(
                requestor: URLSessionRequestor(),
                interceptor: AuthInterceptor(
                    tokenProvider: tokenProvider
                )
            )
        }
    }
}

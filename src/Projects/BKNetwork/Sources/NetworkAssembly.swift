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
            @Autowired var tokenProvider: TokenProvider
            return OAuthNetworkProvider(
                requestor: URLSessionRequestor(),
                interceptor: AuthInterceptor(
                    tokenProvider: tokenProvider
                ),
                authRetrier: AuthRetrier(
                    refreshHandler: { token in
                        @Autowired var handler: RefreshHandler
                        return handler.refresh(token: token)
                            .mapError { _ in NetworkError.retryFailed }
                            .eraseToAnyPublisher()
                    },
                    tokenProvider: tokenProvider
                )
            )
        }
    }
}

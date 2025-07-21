// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import Foundation

public struct NetworkAssembly: Assembly {
    public init() {}
    
    public func assemble(container: DIContainer) {
        container.register(
            type: NetworkProvider.self,
            name: "Default"
        ) { _ in
            return DefaultNetworkProvider(
                requestor: URLSessionRequestor()
            )
        }
        
        container.register(
            type: NetworkProvider.self,
            name: "OAuth"
        ) { _ in
            @Autowired var tokenProvider: TokenProvider
            @Autowired var tokenStore: TokenStore
            return OAuthNetworkProvider(
                requestor: URLSessionRequestor(),
                interceptor: AuthInterceptor(
                    tokenProvider: tokenProvider
                ),
                authRetrier: AuthRetrier(
                    refreshHandler: { refreshToken in
                        @Autowired var plainProvider: NetworkProvider
                        return plainProvider
                            .request(target: AuthAPI.refresh(token: refreshToken), type: AuthLoginResponseDTO.self)
                            .flatMap { tokens in
                                return tokenStore.save(
                                    accessToken: tokens.accessToken,
                                    refreshToken: tokens.refreshToken
                                )
                                .handleEvents(receiveOutput: { _ in
                                    tokenProvider.clearCache()
                                })
                                .mapError { _ in NetworkError.badRequest }
                            }
                            .debugError("[Refresh]", logger: AppLogger.storage)
                            .eraseToAnyPublisher()
                    },
                    tokenProvider: tokenProvider
                )
            )
        }
    }
}

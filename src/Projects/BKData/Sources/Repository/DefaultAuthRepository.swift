// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

/// NetworkProvider는 반드시 OAuthNetworkProvider로
public struct DefaultAuthRepository: AuthRepository {
    private let networkProvider: NetworkProvider
    private let tokenStore: TokenStore
    private let tokenProvider: TokenProvider
    
    public init(
        networkProvider: NetworkProvider,
        tokenStore: TokenStore,
        tokenProvider: TokenProvider
    ) {
        self.networkProvider = networkProvider
        self.tokenStore = tokenStore
        self.tokenProvider = tokenProvider
    }
    
    public func login(
        provider: AuthProvider,
        token: String
    ) -> AnyPublisher<Void, AuthError> {
        return networkProvider.request(
            target: AuthAPI.login(
                provider: provider,
                token: token
            ),
            type: AuthLoginResponseDTO.self
        )
        .mapError { AuthError.serverError(message: "\($0)") }
        .debugError("[Login]", logger: AppLogger.network)
        .flatMap { tokens in
            return tokenStore.save(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken
            )
            .mapError { _ in AuthError.missingToken }
        }
        .debugError("[Login]", logger: AppLogger.storage)
        .eraseToAnyPublisher()
    }
    
    public func logout() -> AnyPublisher<Void, AuthError> {
        return networkProvider.request(
            target: AuthAPI.logout,
            type: EmptyResponse.self
        )
        .mapError { AuthError.serverError(message: "\($0)") }
        .debugError("[Logout]", logger: AppLogger.network)
        .flatMap { _ in
            tokenProvider.clearCache()
            return tokenStore
                .clear()
                .mapError { _ in AuthError.missingToken }
        }
        .debugError("[Logout]", logger: AppLogger.storage)
        .eraseToAnyPublisher()
    }
    
    public func deleteAccount(
        provider: AuthProvider,
        token: String?
    ) -> AnyPublisher<Void, AuthError> {
        // TODO: - 현재 탈퇴 API가 없으므로 logout으로 대체
        return networkProvider.request(
            target: AuthAPI.logout,
            type: EmptyResponse.self
        )
        .mapError { AuthError.serverError(message: "\($0)") }
        .flatMap { _ in
            tokenProvider.clearCache()
            return tokenStore
                .clear()
                .mapError { _ in AuthError.missingToken }
        }
        .eraseToAnyPublisher()
    }
}

extension DefaultAuthRepository: RefreshHandler {
    public func refresh(token accessToken: String) -> AnyPublisher<Void, AuthError> {
        return networkProvider.request(
            target: AuthAPI.refresh(
                token: accessToken
            ),
            type: AuthLoginResponseDTO.self
        )
        .mapError { AuthError.serverError(message: "\($0)") }
        .debugError("[Refresh]", logger: AppLogger.network)
        .flatMap { tokens in
            return tokenStore.save(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken
            )
            .mapError { _ in AuthError.missingToken }
        }
        .debugError("[Refresh]", logger: AppLogger.storage)
        .eraseToAnyPublisher()
    }
}

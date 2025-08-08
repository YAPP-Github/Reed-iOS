// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

public struct DefaultAuthStateRepository: AuthStateRepository {
    private let networkProvider: NetworkProvider
    private let tokenProvider: TokenProvider
    
    public init(
        networkProvider: NetworkProvider,
        tokenProvider: TokenProvider
    ) {
        self.networkProvider = networkProvider
        self.tokenProvider = tokenProvider
    }
    
    public func isLoggedIn() -> AnyPublisher<Bool, Never> {
        return Just(tokenProvider.accessToken != nil)
            .eraseToAnyPublisher()
    }
    
    public func validate() -> AnyPublisher<UserProfile, AuthError> {
        networkProvider.request(
            target: UserAPI.me,
            type: UserProfileResponseDTO.self
        )
        .mapError { _ in AuthError.missingToken }
        .debugError(logger: AppLogger.network)
        .map { return $0.toUserProfile() }
        .eraseToAnyPublisher()
    }
    
    public func updateTermsAgreement(isAgreed: Bool) -> AnyPublisher<Bool, AuthError> {
        networkProvider.request(
            target: UserAPI.termsAgreement(termsAgreed: isAgreed),
            type: UserProfileResponseDTO.self
        )
        .mapError { networkError -> AuthError in
            return .serverError(message: networkError.localizedDescription)
        }
        .debugError(logger: AppLogger.network)
        .map { return $0.termsAgreed }
        .eraseToAnyPublisher()
    }
    
}

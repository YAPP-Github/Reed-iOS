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
    
    public func validate() -> AnyPublisher<Void, AuthError> {
        networkProvider.request(
            target: AuthAPI.me,
            type: EmptyResponse.self
        )
        .mapError { _ in AuthError.missingToken }
        .map { _ in }
        .eraseToAnyPublisher()
    }
    
    public func putTermsAgreement(isAgreed: Bool) -> AnyPublisher<Bool, AuthError> {
        networkProvider.request(
            target: AuthAPI.termsAgreement(termsAgreed: isAgreed),
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

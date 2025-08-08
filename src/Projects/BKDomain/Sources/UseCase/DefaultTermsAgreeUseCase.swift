// Copyright © 2025 Booket. All rights reserved

import BKCore
import Combine
import Foundation

public struct DefaultTermsAgreeUseCase: TermsAgreeUseCase {
    private let authStateRepository: AuthStateRepository
    
    public init(
        authStateRepository: AuthStateRepository
    ) {
        self.authStateRepository = authStateRepository
    }
    
    public func execute(_ isAgreed: Bool) -> AnyPublisher<Bool, DomainError> {
        authStateRepository
            .updateTermsAgreement(isAgreed: isAgreed)
            .debugError(logger: AppLogger.auth)
            .mapError { _ in DomainError.internalServerError }
            .eraseToAnyPublisher()
    }
}

// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefautWithdrawAccountUseCase: WithdrawAccountUseCase {
    private let repository: AuthRepository
    
    public init(repository: AuthRepository) {
        self.repository = repository
    }
    
    public func execute() -> AnyPublisher<Void, AuthError> {
        repository.withdraw()
    }
}

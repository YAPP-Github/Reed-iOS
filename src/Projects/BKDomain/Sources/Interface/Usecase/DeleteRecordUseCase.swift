// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol DeleteRecordUseCase {
    func execute(
        recordId: String
    ) -> AnyPublisher<Void, DomainError>
}

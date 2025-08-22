// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultDeleteRecordUseCase: DeleteRecordUseCase {
    private let repository: RecordRepository
    
    public init(repository: RecordRepository) {
        self.repository = repository
    }
    
    public func execute(
        recordId: String
    ) -> AnyPublisher<Void, DomainError> {
        repository.delete(recordId: recordId)
    }
}

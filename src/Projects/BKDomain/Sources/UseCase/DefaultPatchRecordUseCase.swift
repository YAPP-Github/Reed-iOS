// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultPatchRecordUseCase: PatchRecordUseCase {
    private let repository: RecordRepository
    
    public init(repository: RecordRepository) {
        self.repository = repository
    }
    
    public func execute(
        recordId: String,
        record: RecordVO
    ) -> AnyPublisher<RecordInfo, DomainError> {
        repository.patch(
            recordId: recordId,
            recordData: record
        )
    }
}

// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol PatchRecordUseCase {
    func execute(
        recordId: String,
        record: RecordVO
    ) -> AnyPublisher<RecordInfo, DomainError>
}

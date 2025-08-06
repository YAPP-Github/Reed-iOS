// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol CreateRecordUseCase {
    func execute(
        bookId: String,
        record: RecordVO
    ) -> AnyPublisher<RecordInfo, Error>
}

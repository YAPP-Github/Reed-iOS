// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultCreateRecordUseCase: CreateRecordUseCase {
    private let repository: RecordRepository
    
    public init(repository: RecordRepository) {
        self.repository = repository
    }
    
    public func execute(
        bookId: String,
        record: RecordVO
    ) -> AnyPublisher<Void, Error> {
        repository.create(bookId: bookId, recordData: record)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

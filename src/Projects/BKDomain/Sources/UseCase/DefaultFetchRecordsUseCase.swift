// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultFetchRecordsUseCase: FetchRecordsUseCase {
    private let repository: RecordRepository
    
    public init(repository: RecordRepository) {
        self.repository = repository
    }
    
    public func execute(
        id: String
    ) -> AnyPublisher<[RecordInfo], Error> {
        repository.fetch(
            bookId: id,
            sortType: .pageNumberDesc
        )
    }
}

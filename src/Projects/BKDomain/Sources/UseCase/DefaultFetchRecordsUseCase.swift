// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultFetchRecordsUseCase: FetchRecordsUseCase {
    private let repository: RecordRepository
    
    public init(repository: RecordRepository) {
        self.repository = repository
    }
    
    public func execute(
        id: String,
        page: Int
    ) -> AnyPublisher<RecordFetchResult, DomainError> {
        repository.fetch(
            bookId: id,
            sortType: .pageNumberDesc,
            page: page
        )
    }
}

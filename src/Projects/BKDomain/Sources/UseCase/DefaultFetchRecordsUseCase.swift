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
    ) -> AnyPublisher<(infos: [RecordInfo], hasMore: Bool, totalCount: Int), DomainError> {
        repository.fetch(
            bookId: id,
            sortType: .pageNumberDesc,
            page: page
        )
    }
}

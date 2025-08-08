// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultFetchRecordDetailUseCase: FetchRecordDetailUseCase {
    private let repository: RecordRepository
    
    public init(repository: RecordRepository) {
        self.repository = repository
    }
    
    public func execute(id: String) -> AnyPublisher<RecordInfo, DomainError> {
        repository.findBy(id: id).eraseToAnyPublisher()
    }
}

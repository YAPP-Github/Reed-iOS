// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol FetchRecordDetailUseCase {
    func execute(id: String) -> AnyPublisher<RecordInfo, DomainError>
}

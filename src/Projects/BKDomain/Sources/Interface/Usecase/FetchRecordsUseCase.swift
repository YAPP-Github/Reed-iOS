// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol FetchRecordsUseCase {
    func execute(
        id: String
    ) -> AnyPublisher<[RecordInfo], Error>
}

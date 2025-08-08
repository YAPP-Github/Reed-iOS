// Copyright © 2025 Booket. All rights reserved

import Combine
import UIKit

public protocol RecordRepository {
    func create(
        bookId: String,
        recordData: RecordVO
    ) -> AnyPublisher<RecordInfo, DomainError>
    
    func fetch(
        bookId: String,
        sortType: LibrarySortType
    ) -> AnyPublisher<[RecordInfo], DomainError>
    
    func findBy(
        id recordId: String
    ) -> AnyPublisher<RecordInfo, DomainError>
}

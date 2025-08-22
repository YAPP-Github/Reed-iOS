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
        sortType: LibrarySortType,
        page: Int
    ) -> AnyPublisher<(infos: [RecordInfo], hasMore: Bool, totalCount: Int), DomainError>
    
    func findBy(
        id recordId: String
    ) -> AnyPublisher<RecordInfo, DomainError>
    
    func patch(
        recordId: String,
        recordData: RecordVO
    ) -> AnyPublisher<RecordInfo, DomainError>
    
    func delete(
        recordId: String
    ) -> AnyPublisher<Void, DomainError>
}

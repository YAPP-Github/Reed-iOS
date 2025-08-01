// Copyright © 2025 Booket. All rights reserved

import Combine
import UIKit

public protocol RecordRepository {
    func create(
        bookId: String,
        recordData: RecordVO
    ) -> AnyPublisher<RecordInfo, Error>
    
    func fetch(
        bookId: String,
        page: Int,
        size: Int,
        sortType: LibrarySortType
    ) -> AnyPublisher<[RecordInfo], Error>
}

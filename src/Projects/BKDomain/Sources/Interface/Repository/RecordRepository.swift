// Copyright © 2025 Booket. All rights reserved

import Combine
import UIKit

public protocol RecordRepository {
    func create(
        bookId: String,
        data: RecordVO
    ) -> AnyPublisher<RecordInfo, Error>
    
//    func fetch() -> AnyPublisher<[RecordInfo], Error>
}

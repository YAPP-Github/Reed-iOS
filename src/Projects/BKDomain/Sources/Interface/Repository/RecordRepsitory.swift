// Copyright © 2025 Booket. All rights reserved

import Combine
import UIKit

public protocol RecordRepsitory {
    func create(
        bookId: String,
        data: RecordVO
    ) -> AnyPublisher<RecordInfo, Error>
    
//    func fetch() -> AnyPublisher<[RecordInfo], Error>
}

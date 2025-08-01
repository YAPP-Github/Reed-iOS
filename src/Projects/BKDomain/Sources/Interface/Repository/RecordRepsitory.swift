// Copyright © 2025 Booket. All rights reserved

import Combine
import UIKit

public protocol RecordRepsitory {
    func createRecord(data: RecordVO) -> AnyPublisher<RecordInfo, Error>
    
    func fetch() -> AnyPublisher<[RecordInfo], Error>
}

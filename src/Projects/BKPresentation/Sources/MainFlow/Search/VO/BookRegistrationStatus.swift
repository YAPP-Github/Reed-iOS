// Copyright © 2025 Booket. All rights reserved

import BKDomain

enum BookRegistrationStatus: String {
    case before = "읽기 전"
    case inProgress = "읽는 중"
    case after = "독서 완료"
    
    func toBookStatus() -> BKDomain.BookStatus {
        switch self {
        case .after:
            return .completed
        case .before:
            return .beforeReading
        case .inProgress:
            return .reading
        }
    }
    
    static func from(_ bookStatus: BKDomain.BookStatus) -> BookRegistrationStatus {
        switch bookStatus {
        case .beforeRegistration, .beforeReading:
            return .before
        case .reading:
            return .inProgress
        case .completed:
            return .after
        }
    }
}

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
    
    func getSubTitle() -> String {
        switch self {
        case .before:
            return "책을 읽으면서 독서 기록을 남길 수 있어요"
        case .inProgress:
            return "독서 기록을 바로 시작할까요?"
        case .after:
            return "기억에 남은 문장이나 감상을 기록해보세요"
        }
    }
    
    func getCancelButtonTitle() -> String {
        switch self {
        case .before:
            return "확인"
        case .inProgress, .after:
            return "나중에 하기"
        }
    }
    
    func getNextButtonTitle() -> String {
        switch self {
        case .inProgress:
            return "기록 시작하기"
        case .after:
            return "기록 남기기"
        default:
            return ""
        }
    }
}

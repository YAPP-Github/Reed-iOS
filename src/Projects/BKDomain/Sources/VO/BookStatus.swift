// Copyright © 2025 Booket. All rights reserved

import Foundation

/// 책 등록 상태 표현
public enum BookStatus: String, Codable {
    case beforeRegistration = "BEFORE_REGISTRATION"
    case beforeReading = "BEFORE_READING"
    case reading = "READING"
    case completed = "COMPLETED"
    
    public var displayName: String {
        switch self {
        case .beforeRegistration:
            return "등록 전"
        case .beforeReading:
            return "읽기 전"
        case .reading:
            return "읽는 중"
        case .completed:
            return "독서 완료"
        }
    }
}

// Copyright © 2025 Booket. All rights reserved

import Foundation

/// 책 등록 상태 표현
public enum BookStatus: String, Codable {
    case before_registeration = "BEFORE_REGISTRATION"
    case before_reading = "BEFORE_READING"
    case reading = "READING"
    case completed = "COMPLETED"
}

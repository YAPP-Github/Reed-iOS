// Copyright © 2025 Booket. All rights reserved

import Foundation

/// 책 등록 상태 표현
public enum BookStatus: String, Codable {
    case beforeRegisteration = "BEFORE_REGISTERATION"
    case beforeReading = "BEFORE_READING"
    case reading = "READING"
    case completed = "COMPLETED"
}

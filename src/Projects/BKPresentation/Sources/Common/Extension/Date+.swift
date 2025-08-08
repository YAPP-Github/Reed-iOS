// Copyright © 2025 Booket. All rights reserved

import Foundation

extension Date {
    private static let koreanFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private static let koreanYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    func toKoreanDateString() -> String {
        return Self.koreanFormatter.string(from: self)
    }
    
    func toKoreanYearString() -> String {
        return Self.koreanYearFormatter.string(from: self)
    }
}

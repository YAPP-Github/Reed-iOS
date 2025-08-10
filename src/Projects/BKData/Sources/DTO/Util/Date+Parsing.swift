// Copyright © 2025 Booket. All rights reserved

import Foundation

public enum DateParser {
    private static let fallbackFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    public static func parse(_ string: String) -> Date? {
        if let date = fallbackFormatter.date(from: string) {
            return date
        }
        return nil
    }
}


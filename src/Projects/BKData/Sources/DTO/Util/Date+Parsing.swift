// Copyright © 2025 Booket. All rights reserved

import Foundation

public enum DateParser {
    private static let fallbackFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private static let isoWithMicroseconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    public static func parse(_ string: String) -> Date? {
        if let date = fallbackFormatter.date(from: string) {
            return date
        }
        return nil
    }
    
    public static func parseISO8601(_ string: String) -> Date? {
        if let date = isoWithMicroseconds.date(from: string) {
            return date
        }
        return nil
    }
}


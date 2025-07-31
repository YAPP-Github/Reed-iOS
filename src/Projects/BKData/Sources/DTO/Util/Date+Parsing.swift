// Copyright © 2025 Booket. All rights reserved

import Foundation

public enum DateParser {
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    public static func parse(_ string: String) -> Date? {
        return iso8601Formatter.date(from: string)
    }
}


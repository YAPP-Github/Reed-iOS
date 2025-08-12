// Copyright © 2025 Booket. All rights reserved

import Foundation
extension Date {
    private static func displayFormatter(_ pattern: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = .autoupdatingCurrent
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = pattern
        return formatter
    }

    func toKoreanDateString() -> String {
        Self.displayFormatter("yyyy-MM-dd").string(from: self)
    }

    func toKoreanYearString() -> String {
        Self.displayFormatter("yyyy년").string(from: self)
    }

    func toKoreanDotDateString() -> String {
        Self.displayFormatter("yyyy.MM.dd").string(from: self)
    }
}

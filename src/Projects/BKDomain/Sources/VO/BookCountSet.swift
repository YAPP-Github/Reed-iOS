// Copyright © 2025 Booket. All rights reserved

import Foundation

/// 내 서재의 도서 상태 별 개수를 표현합니다.(내 서재 상단 칩)
public struct BookCountSet {
    public let totalCount: Int
    public let beforeReadingCount: Int
    public let readingCount: Int
    public let completedCount: Int
    
    public init(
        totalCount: Int,
        beforeReadingCount: Int,
        readingCount: Int,
        completedCount: Int
    ) {
        self.totalCount = totalCount
        self.beforeReadingCount = beforeReadingCount
        self.readingCount = readingCount
        self.completedCount = completedCount
    }
}

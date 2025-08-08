// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct HomeInfo: Equatable {
    public let userBookId: String
    public let title: String
    public let author: String
    public let publisher: String
    public let coverImageUrl: URL
    public let lastRecordedAt: Date?
    public let recordCount: Int
    
    public init(
        userBookId: String,
        title: String,
        author: String,
        publisher: String,
        coverImageUrl: URL,
        lastRecordedAt: Date?,
        recordCount: Int
    ) {
        self.userBookId = userBookId
        self.title = title
        self.author = author
        self.publisher = publisher
        self.coverImageUrl = coverImageUrl
        self.lastRecordedAt = lastRecordedAt
        self.recordCount = recordCount
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

public struct HomeBookInfo: Equatable {
    let userBookId: String
    let isbn13: String
    let title: String
    let author: String
    let publisher: String
    let coverImageUrl: URL?
    let lastRecordedAt: Date?
    let recordCount: Int
    
    public init(
        userBookId: String,
        isbn13: String,
        title: String,
        author: String,
        publisher: String,
        coverImageUrl: URL?,
        lastRecordedAt: Date?,
        recordCount: Int
    ) {
        self.userBookId = userBookId
        self.isbn13 = isbn13
        self.title = title
        self.author = author
        self.publisher = publisher
        self.coverImageUrl = coverImageUrl
        self.lastRecordedAt = lastRecordedAt
        self.recordCount = recordCount
    }
    
    static func from(_ homeInfo: HomeInfo) -> Self {
        return HomeBookInfo(
            userBookId: homeInfo.userBookId,
            isbn13: homeInfo.isbn13,
            title: homeInfo.title,
            author: homeInfo.author,
            publisher: homeInfo.publisher,
            coverImageUrl: homeInfo.coverImageUrl,
            lastRecordedAt: homeInfo.lastRecordedAt,
            recordCount: homeInfo.recordCount
        )
    }
}

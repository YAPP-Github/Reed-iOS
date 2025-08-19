// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct Book: Hashable {
    public let isbn: String
    public let title: String
    public let author: String
    public let pubDate: Date?
    public let publisher: String
    public let thumbnail: URL?
    public let userBookStatus: BookStatus?
    public let recordCount: Int?
    
    public init(
        isbn: String,
        title: String,
        author: String,
        pubDate: Date? = nil,
        publisher: String,
        thumbnail: URL?,
        userBookStatus: BookStatus?,
        recordCount: Int? = nil
    ) {
        self.isbn = isbn
        self.title = title
        self.author = author
        self.pubDate = pubDate
        self.publisher = publisher
        self.thumbnail = thumbnail
        self.userBookStatus = userBookStatus
        self.recordCount = recordCount
    }
}

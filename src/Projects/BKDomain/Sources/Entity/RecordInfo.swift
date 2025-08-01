// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct RecordInfo: Decodable {
    public let recordId: String
    public let bookId: String
    public let pageNumber: Int
    public let quote: String?
    public let review: String?
    public let emotionTags: [String]
    public let createdAt: Date
    public let updatedAt: Date?
    public let bookTitle: String
    public let bookPublisher: String
    public let bookCoverImageUrl: URL?
    
    public init(
        recordId: String,
        bookId: String,
        pageNumber: Int,
        quote: String?,
        review: String?,
        emotionTags: [String],
        createdAt: Date,
        updatedAt: Date?,
        bookTitle: String,
        bookPublisher: String,
        bookCoverImageUrl: URL?
    ) {
        self.recordId = recordId
        self.bookId = bookId
        self.pageNumber = pageNumber
        self.quote = quote
        self.review = review
        self.emotionTags = emotionTags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.bookTitle = bookTitle
        self.bookPublisher = bookPublisher
        self.bookCoverImageUrl = bookCoverImageUrl
    }
}

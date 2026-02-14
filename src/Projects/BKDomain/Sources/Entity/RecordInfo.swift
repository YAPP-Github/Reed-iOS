// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct RecordInfo: Decodable, Equatable {
    public let recordId: String
    public let bookId: String
    public let pageNumber: Int?
    public let quote: String
    public let review: String?
    public let primaryEmotion: PrimaryEmotion
    public let detailEmotions: [DetailEmotion]
    public let createdAt: Date
    public let updatedAt: Date?
    public let bookTitle: String
    public let bookPublisher: String
    public let bookCoverImageUrl: URL
    public let author: String

    public init(
        recordId: String,
        bookId: String,
        pageNumber: Int?,
        quote: String,
        review: String?,
        primaryEmotion: PrimaryEmotion,
        detailEmotions: [DetailEmotion],
        createdAt: Date,
        updatedAt: Date?,
        bookTitle: String,
        bookPublisher: String,
        bookCoverImageUrl: URL,
        author: String
    ) {
        self.recordId = recordId
        self.bookId = bookId
        self.pageNumber = pageNumber
        self.quote = quote
        self.review = review
        self.primaryEmotion = primaryEmotion
        self.detailEmotions = detailEmotions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.bookTitle = bookTitle
        self.bookPublisher = bookPublisher
        self.bookCoverImageUrl = bookCoverImageUrl
        self.author = author
    }

    /// 이전 API와의 호환성을 위한 computed property
    public var emotionTags: [Emotion] {
        [primaryEmotion.toEmotion()]
    }
}

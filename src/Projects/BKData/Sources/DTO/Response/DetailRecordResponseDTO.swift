// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

public struct DetailRecordResponseDTO: Decodable {
    public let id: String
    public let userBookId: String
    public let pageNumber: Int
    public let quote: String
    public let review: String
    public let emotionTags: [Emotion]
    public let createdAt: String
    public let updatedAt: String
    public let bookTitle: String
    public let bookPublisher: String
    public let bookCoverImageUrl: URL
    public let author: String
}

extension DetailRecordResponseDTO {
    func toRecordInfo() -> RecordInfo {
        return RecordInfo(
            recordId: id,
            bookId: userBookId,
            pageNumber: pageNumber,
            quote: quote,
            review: review,
            emotionTags: emotionTags,
            createdAt: DateParser.parse(createdAt) ?? .distantPast,
            updatedAt: DateParser.parse(updatedAt),
            bookTitle: bookTitle,
            bookPublisher: bookPublisher,
            bookCoverImageUrl: bookCoverImageUrl,
            author: author
        )
    }
}

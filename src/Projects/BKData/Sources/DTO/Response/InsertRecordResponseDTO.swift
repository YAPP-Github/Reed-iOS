// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

public struct InsertRecordResponseDTO: Decodable {
    let id: String
    let userBookId: String
    let pageNumber: Int
    let quote: String
    let review: String
    let emotionTags: [Emotion]
    let createdAt: String
    let updatedAt: String
    let bookTitle: String
    let bookPublisher: String
    let bookCoverImageUrl: URL
    let author: String

    enum CodingKeys: String, CodingKey {
        case id
        case userBookId
        case pageNumber
        case quote
        case review
        case emotionTags
        case createdAt
        case updatedAt
        case bookTitle
        case bookPublisher
        case bookCoverImageUrl
        case author
    }
}

public extension InsertRecordResponseDTO {
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

// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

struct InsertRecordResponseDTO: Decodable {
    let id: String
    let userBookId: String
    let pageNumber: Int?
    let quote: String
    let review: String?
    let primaryEmotion: PrimaryEmotionDTO
    let detailEmotions: [DetailEmotionDTO]
    let createdAt: String
    let updatedAt: String
    let bookTitle: String
    let bookPublisher: String
    let bookCoverImageUrl: URL
    let author: String
}

extension InsertRecordResponseDTO {
    func toRecordInfo() -> RecordInfo {
        return RecordInfo(
            recordId: id,
            bookId: userBookId,
            pageNumber: pageNumber,
            quote: quote,
            review: review,
            primaryEmotion: primaryEmotion.toDomain() ?? .other,
            detailEmotions: detailEmotions.map { $0.toDomain() },
            createdAt: DateParser.parseISO8601(createdAt) ?? .distantPast,
            updatedAt: DateParser.parseISO8601(updatedAt),
            bookTitle: bookTitle,
            bookPublisher: bookPublisher,
            bookCoverImageUrl: bookCoverImageUrl,
            author: author
        )
    }
}

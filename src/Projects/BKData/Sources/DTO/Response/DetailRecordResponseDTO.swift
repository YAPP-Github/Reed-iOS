// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

struct DetailRecordResponseDTO: Decodable {
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

extension DetailRecordResponseDTO {
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

// api-v2
public struct DetailRecordV2ResponseDTO: Decodable {
    public let id: String
    public let userBookId: String
    public let pageNumber: Int?
    public let quote: String
    public let review: String?
    public let primaryEmotion: PrimaryEmotionResponseDTO
    public let detailEmotions: [DetailEmotionResponseDTO]
    public let createdAt: String
    public let updatedAt: String
    public let bookTitle: String
    public let bookPublisher: String
    public let bookCoverImageUrl: URL
    public let author: String
}

extension DetailRecordV2ResponseDTO {
    func toRecordInfo() -> RecordInfo {
        return RecordInfo(
            recordId: id,
            bookId: userBookId,
            pageNumber: pageNumber,
            quote: quote,
            review: review,
            primaryEmotion: primaryEmotion.toDomain(),
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

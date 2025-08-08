// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

public struct UserBookResponseDTO: Decodable {
    let id: String
    let userID: String
    let isbn: String
    let title: String
    let author: String
    let status: BookStatus
    let coverURL: URL
    let publisher: String
    let createdDate: String
    let updatedDate: String
    let recordCount: Int

    enum CodingKeys: String, CodingKey {
        case id = "userBookId"
        case userID = "userId"
        case isbn = "bookIsbn"
        case title = "bookTitle"
        case author = "bookAuthor"
        case status
        case coverURL = "coverImageUrl"
        case publisher
        case createdDate = "createdAt"
        case updatedDate = "updatedAt"
        case recordCount
    }

    public func toBookInfo() -> BookInfo {
        return BookInfo(
            bookId: id,
            isbn: isbn,
            title: title,
            author: author,
            status: status,
            imageUrl: coverURL,
            publisher: publisher,
            createdAt: DateParser.parse(createdDate),
            updatedAt: DateParser.parse(updatedDate),
            recordCount: recordCount
        )
    }
}

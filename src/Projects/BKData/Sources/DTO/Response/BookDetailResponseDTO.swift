// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

struct BookDetailResponseDTO: Decodable {
    let version: String
    let title: String
    let link: URL
    let author: String
    let pubDate: String
    let description: String
    let isbn13: String
    let mallType: String
    let coverImageUrl: URL
    let categoryName: String
    let publisher: String
    let totalPage: Int
    let userBookStatus: BookStatus
}

extension BookDetailResponseDTO {
    func toBook() -> Book {
        return Book(
            isbn: isbn13,
            title: title,
            author: author,
            pubDate: DateParser.parse(pubDate),
            publisher: publisher,
            thumbnail: coverImageUrl,
            userBookStatus: userBookStatus
        )
    }
}

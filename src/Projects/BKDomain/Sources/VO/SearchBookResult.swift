// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct SearchBookResult: Decodable {
    public let isbn13: String
    public let title: String
    public let author: String
    public let publisher: String
    public let coverImageUrl: URL
    public let userBookStatus: BookStatus
}

public extension SearchBookResult {
    func toBook() -> Book {
        return Book(
            isbn: isbn13,
            title: title,
            author: author,
            publisher: publisher,
            thumbnail: coverImageUrl,
            userBookStatus: userBookStatus
        )
    }
}

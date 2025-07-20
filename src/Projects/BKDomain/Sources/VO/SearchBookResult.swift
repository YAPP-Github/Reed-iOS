// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct SearchBookResult: Decodable {
    public let isbn: String
    public let title: String
    public let author: String
    public let publisher: String
    public let coverImageUrl: String
    public let userBookStatus: String
}

public extension SearchBookResult {
    func toBook() -> Book {
        return Book(
            isbn: isbn,
            title: title,
            author: author,
            publisher: publisher,
            thumbnail: URL(string: coverImageUrl),
            userBookStatus: userBookStatus
        )
    }
}

// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct BookInfo: Equatable {
    public let bookId: String
    public let isbn: String
    public let title: String
    public let author: String
    public let status: BookStatus
    public let imageUrl: URL?
    public let publisher: String
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(
        bookId: String,
        isbn: String,
        title: String,
        author: String,
        status: BookStatus,
        imageUrl: URL?,
        publisher: String,
        createdAt: Date?,
        updatedAt: Date?
    ) {
        self.bookId = bookId
        self.isbn = isbn
        self.title = title
        self.author = author
        self.status = status
        self.imageUrl = imageUrl
        self.publisher = publisher
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

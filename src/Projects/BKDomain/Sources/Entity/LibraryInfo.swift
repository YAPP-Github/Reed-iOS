// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct LibraryInfo {
    public let currentPage: Int?
    public let count: BookCountSet
    public let books : [BookInfo]
    
    public init(
        currentPage: Int?,
        count: BookCountSet,
        books: [BookInfo]
    ) {
        self.currentPage = currentPage
        self.count = count
        self.books = books
    }
}

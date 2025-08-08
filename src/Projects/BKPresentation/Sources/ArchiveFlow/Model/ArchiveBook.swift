// Copyright © 2025 Booket. All rights reserved

import BKDomain
import UIKit

struct ArchiveBook: Hashable, Equatable {
    let isbn: String
    let bookId: String
    let title: String
    let author: String
    let publisher: String
    let status: BKDomain.BookStatus
    let imageURL: URL?
    let recordCount: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(isbn)
    }
    
    static func == (
        lhs: ArchiveBook,
        rhs: ArchiveBook
    ) -> Bool {
        lhs.isbn == rhs.isbn
    }
}

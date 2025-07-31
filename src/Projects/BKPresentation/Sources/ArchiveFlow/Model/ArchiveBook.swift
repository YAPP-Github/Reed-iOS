// Copyright © 2025 Booket. All rights reserved

import UIKit

struct ArchiveBook: Hashable, Equatable {
    let isbn: String
    let title: String
    let author: String
    let publisher: String
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

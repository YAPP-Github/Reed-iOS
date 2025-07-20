// Copyright © 2025 Booket. All rights reserved

public enum SearchTarget: String, Encodable {
    case book = "Book"
    case foreign = "Foreign"
    case ebook = "Ebook"
}

extension SearchTarget: CustomStringConvertible {
    public var description: String { rawValue }
}

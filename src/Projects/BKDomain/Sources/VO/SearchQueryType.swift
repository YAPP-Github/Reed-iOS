// Copyright © 2025 Booket. All rights reserved

public enum SearchQueryType: String, Encodable {
    case title = "Title"
    case author = "Author"
    case publisher = "Publisher"
}

extension SearchQueryType: CustomStringConvertible {
    public var description: String { rawValue }
}

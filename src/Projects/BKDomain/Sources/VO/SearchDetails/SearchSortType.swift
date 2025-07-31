// Copyright © 2025 Booket. All rights reserved

public enum SearchSortType: String, Encodable {
    case accuracy = "Accuracy"
    case publishTime = "PublishTime"
    case salesPoint = "SalesPoint"
}

extension SearchSortType: CustomStringConvertible {
    public var description: String { rawValue }
}

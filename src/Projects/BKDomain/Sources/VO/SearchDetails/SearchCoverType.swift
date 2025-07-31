// Copyright © 2025 Booket. All rights reserved

public enum SearchCoverType: String, Encodable {
    case small = "Small"
    case mid = "Mid"
    case big = "Big"
}

extension SearchCoverType: CustomStringConvertible {
    public var description: String { rawValue }
}

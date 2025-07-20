// Copyright © 2025 Booket. All rights reserved

public struct SearchBookParameters {
    public var query: String
    public var queryType: SearchQueryType? = nil
    public var searchTarget: SearchTarget? = nil
    public var maxResults: Int? = 10
    public var start: Int? = 1
    public var sort: SearchSortType? = nil
    public var cover: SearchCoverType? = nil
    public var categoryId: Int? = nil
}

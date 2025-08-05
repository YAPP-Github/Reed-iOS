// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct MyLibraryParameters {
    public var status: BookStatus?
    public var sortType: LibrarySortType?
    public var pageNumber: Int?
    public var pageSize: Int?
    public var title: String?
    
    init(
        status: BookStatus? = nil,
        sortType: LibrarySortType? = nil,
        pageNumber: Int? = 0,
        pageSize: Int? = 10,
        title: String? = nil
    ) {
        self.status = status
        self.sortType = sortType
        self.pageNumber = pageNumber
        self.pageSize = pageSize
        self.title = title
    }
}

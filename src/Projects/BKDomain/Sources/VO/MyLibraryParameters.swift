// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct MyLibraryParameters {
    public var status: BookStatus
    public var sortType: LibrarySortType
    public var pageNumber: Int? = 0
    public var pageSize: Int? = 10
    public var title: String?
}

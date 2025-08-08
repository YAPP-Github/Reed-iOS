// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

struct LibraryRequestDTO: DictionaryRepresentable {
    let title: String?
    let status: String?
    let sort: LibrarySortType?
    let page: Int?
    let size: Int?
    
    var dictionary: [String: Any] {
        return self.toDictionary()
    }
    
    init(
        title: String? = nil,
        status: BookStatus? = nil,
        sortType: LibrarySortType? = nil,
        pageNumber: Int? = nil,
        pageSize: Int? = nil
    ) {
        self.title = title
        self.status = status?.rawValue
        self.sort = sortType
        self.page = pageNumber
        self.size = pageSize
    }
    
    init(_ entity: MyLibraryParameters) {
        self.init(
            title: entity.title,
            status: entity.status,
            sortType: entity.sortType,
            pageNumber: entity.pageNumber,
            pageSize: entity.pageSize
        )
    }
}

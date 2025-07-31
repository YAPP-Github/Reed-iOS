// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

struct LibraryRequestDTO: DictionaryRepresentable {
    let title: String?
    let status: BookStatus
    let sortType: LibrarySortType
    let pageNumber: Int?
    let pageSize: Int?
    
    var dictionary: [String: Any] {
        return self.toDictionary()
    }
    
    init(
        title: String?,
        status: BookStatus,
        sortType: LibrarySortType,
        pageNumber: Int?,
        pageSize: Int?
    ) {
        self.title = title
        self.status = status
        self.sortType = sortType
        self.pageNumber = pageNumber
        self.pageSize = pageSize
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

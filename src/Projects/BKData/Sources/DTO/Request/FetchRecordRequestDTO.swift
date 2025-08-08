// Copyright © 2025 Booket. All rights reserved

import BKDomain

struct FetchRecordRequestDTO: DictionaryRepresentable {
    let page: Int?
    let size: Int?
    let sort: LibrarySortType
    
    init(
        page: Int? = nil,
        size: Int? = nil,
        sort: LibrarySortType
    ) {
        self.page = page
        self.size = size
        self.sort = sort
    }
}

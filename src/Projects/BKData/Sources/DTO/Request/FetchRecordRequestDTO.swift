// Copyright © 2025 Booket. All rights reserved

import BKDomain

struct FetchRecordRequestDTO: DictionaryRepresentable {
    let page: Int
    let size: Int
    let sort: LibrarySortType
}

// Copyright © 2025 Booket. All rights reserved

import BKDomain

struct SearchBookRequestDTO: DictionaryRepresentable {
    let query: String?
    let queryType: SearchQueryType?
    let searchTarget: SearchTarget?
    let maxResults: Int?
    let start: Int?
    let sort: SearchSortType?
    let cover: SearchCoverType?
    let categoryId: Int?
    
    var dictionary: [String: Any] {
        return self.toDictionary()
    }
}

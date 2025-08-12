// Copyright © 2025 Booket. All rights reserved

import BKDomain

struct SearchBookResponseDTO: Decodable {
    let version: String
    let title: String
    let pubDate: String
    let totalResults: Int
    let startIndex: Int
    let itemsPerPage: Int
    let query: String
    let searchCategoryId: Int
    let searchCategoryName: String
    let books: [SearchBookResult]
}

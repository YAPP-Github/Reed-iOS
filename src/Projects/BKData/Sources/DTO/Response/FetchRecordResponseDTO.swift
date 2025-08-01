// Copyright © 2025 Booket. All rights reserved

import Foundation

struct FetchRecordResponseDTO<T: Decodable>: Decodable {
    let totalPages: Int
    let totalElements: Int
    let size: Int
    let content: [T]
    let number: Int
    let sort: Sort
    let numberOfElements: Int
    let pageable: Pageable
    let first: Bool
    let last: Bool
    let empty: Bool

    struct Sort: Decodable {
        let empty: Bool
        let sorted: Bool
        let unsorted: Bool
    }

    struct Pageable: Decodable {
        let offset: Int
        let sort: Sort
        let pageSize: Int
        let paged: Bool
        let pageNumber: Int
        let unpaged: Bool
    }
}

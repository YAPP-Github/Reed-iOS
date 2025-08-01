// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

struct FetchHomeResponseDTO: Decodable {
    let recentBooks: [HomeDTO]
}

struct HomeDTO: Decodable {
    let userBookId: String
    let title: String
    let author: String
    let publisher: String
    let coverImageUrl: String
    let lastRecordedAt: String
    let recordCount: Int
}

extension HomeDTO {
    func toEntity() -> HomeInfo {
        return HomeInfo(
            userBookId: userBookId,
            title: title,
            author: author,
            publisher: publisher,
            coverImageUrl: URL(string: coverImageUrl),
            lastRecordedAt: DateParser.parse(lastRecordedAt),
            recordCount: recordCount
        )
    }
}

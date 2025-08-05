// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

public struct UserLibraryResponseDTO: Decodable {
    let books: PaginatedBooksDTO
    let beforeReadingCount: Int
    let readingCount: Int
    let completedCount: Int
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case books
        case beforeReadingCount
        case readingCount
        case completedCount
        case totalCount
    }
    
    public func toBookCountSet() -> BookCountSet {
        return BookCountSet(
            totalCount: self.totalCount,
            beforeReadingCount: self.beforeReadingCount,
            readingCount: self.readingCount,
            completedCount: self.completedCount
        )
    }
    
    /// 다음 페이지 번호를 반환합니다.
    /// 마지막 페이지인 경우 nil을 반환합니다.
    public func nextPageNumber() -> Int? {
        let next = books.page.number + 1
        return next < books.page.totalPages ? next : nil
    }
    
    public func getBookInfos() -> [BookInfo] {
        return books.content.map { $0.toBookInfo() }
    }
}

public struct PaginatedBooksDTO: Decodable {
    let content: [UserBookResponseDTO]
    let page: PageInfoDTO

    enum CodingKeys: String, CodingKey {
        case content
        case page
    }

}

public struct PageInfoDTO: Decodable {
    let size: Int
    let number: Int
    let totalElements: Int
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case size
        case number
        case totalElements
        case totalPages
    }
}

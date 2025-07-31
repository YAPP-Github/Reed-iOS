// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol BookRepository {
    func search(
        _ parameters: SearchBookParameters
    ) -> AnyPublisher<([Book], totalResults: Int), Never>
    
//    func detail() -> AnyPublisher<Void, Never>
    
    /// 내 서재를 조회하고 검색합니다.
    func myLibrary(
        _ parameters: MyLibraryParameters
    ) -> AnyPublisher<LibraryInfo, Error>
    
    /// 내 서재에 도서를 등록합니다
    func upsert(
        _ bookIsbn: String,
        _ status: BookStatus
    ) -> AnyPublisher<BookInfo, Error>
}

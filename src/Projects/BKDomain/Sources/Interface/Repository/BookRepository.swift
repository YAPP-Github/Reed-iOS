// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol BookRepository {
    func search(
        _ parameters: SearchBookParameters
    ) -> AnyPublisher<([Book], totalResults: Int), Never>
    
//    func detail() -> AnyPublisher<Void, Never>
//    func myLibrary() -> AnyPublisher<[Book], Never>
    
    /// 내 서재에 도서를 등록합니다
    func upsert(
        _ bookIsbn: String,
        _ status: BookStatus
    ) -> AnyPublisher<BookInfo, Error>
}

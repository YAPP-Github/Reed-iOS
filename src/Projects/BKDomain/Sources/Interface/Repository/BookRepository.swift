// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol BookRepository {
    /// 전체 도서 검색에 특화된 기능입니다.
    func search(
        _ parameters: SearchBookParameters
    ) -> AnyPublisher<([Book], totalResults: Int), Never>
    
    /// 내 서재 검색에 특화된 기능입니다.
    func searchMyLibrary(
        _ parameters: MyLibraryParameters
    ) -> AnyPublisher<([Book], totalResults: Int), Never>
    
    /// 내 서재를 조회합니다.
    func myLibrary(
        _ parameters: MyLibraryParameters
    ) -> AnyPublisher<LibraryInfo, Error>
    
    /// 내 서재에 도서를 등록합니다
    func upsert(
        _ bookIsbn: String,
        _ status: BookStatus
    ) -> AnyPublisher<BookInfo, Error>
}

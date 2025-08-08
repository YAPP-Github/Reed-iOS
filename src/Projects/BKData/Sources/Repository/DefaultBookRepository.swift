// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

public struct DefaultBookRepository: BookRepository {
    private let networkProvider: NetworkProvider
    
    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }
    
    public func search(
        _ parameters: SearchBookParameters
    ) -> AnyPublisher<([Book], totalResults: Int), DomainError> {
        networkProvider.request(
            target: BookAPI.search(
                dto: SearchBookRequestDTO(
                    query: parameters.query,
                    queryType: parameters.queryType,
                    searchTarget: parameters.searchTarget,
                    maxResults: parameters.maxResults,
                    start: parameters.start,
                    sort: parameters.sort,
                    cover: parameters.cover,
                    categoryId: parameters.categoryId
                )
            ),
            type: SearchBookResponseDTO.self
        )
        .debugError(logger: AppLogger.network)
        .mapError { $0.toDomainError() }
        .map { dto in
            let books = dto.books.map { $0.toBook() }
            return (books, dto.totalResults)
        }
        .eraseToAnyPublisher()
    }
    
    public func searchMyLibrary(
        _ parameters: MyLibraryParameters
    ) -> AnyPublisher<([BookInfo], totalResults: BookCountSet), DomainError> {
        networkProvider.request(
            target: BookAPI.myLibrary(
                parameter: LibraryRequestDTO(parameters)
            ),
            type: UserLibraryResponseDTO.self
        )
        .map { ($0.getBookInfos(), $0.toBookCountSet()) }
        .mapError { $0.toDomainError() }
        .eraseToAnyPublisher()
    }
    
    public func myLibrary(
        _ parameters: MyLibraryParameters
    ) -> AnyPublisher<LibraryInfo, DomainError> {
        networkProvider.request(
            target: BookAPI.myLibrary(
                parameter: LibraryRequestDTO(parameters)
            ),
            type: UserLibraryResponseDTO.self
        )
        .mapError { $0.toDomainError() }
        .debugError(logger: AppLogger.network)
        .map {
            return LibraryInfo(
                currentPage: $0.nextPageNumber(),
                count: $0.toBookCountSet(),
                books: $0.getBookInfos()
            )
        }
        .eraseToAnyPublisher()
    }
    
    public func upsert(
        _ bookIsbn: String,
        _ status: BookStatus
    ) -> AnyPublisher<BookInfo, DomainError> {
        networkProvider.request(
            target: BookAPI.upsert(
                dto: UserBookRegisterRequestDTO(
                    isbn13: bookIsbn,
                    bookStatus: status
                )
            ),
            type: UserBookResponseDTO.self
        )
        .mapError { $0.toDomainError() }
        .debugError(logger: AppLogger.network)
        .map { return $0.toBookInfo() }
        .eraseToAnyPublisher()
    }
    
    public func detail(
        isbn: String
    ) -> AnyPublisher<Book, DomainError> {
        networkProvider.request(
            target: BookAPI.detail(isbn: isbn),
            type: BookDetailResponseDTO.self
        )
        .mapError { $0.toDomainError() }
        .debugError(logger: AppLogger.network)
        .map { $0.toBook() }
        .eraseToAnyPublisher()
    }
}

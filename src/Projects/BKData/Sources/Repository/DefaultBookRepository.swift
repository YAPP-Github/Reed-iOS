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
    ) -> AnyPublisher<([Book], totalResults: Int), Never> {
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
        .map { dto in
            let books = dto.books.map { $0.toBook() }
            return (books, dto.totalResults)
        }
        .catch { _ in Just(([], 0)) }
        .eraseToAnyPublisher()
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

public final class DefaultRecordRepository: RecordRepository {
    private let networkProvider: NetworkProvider
    
    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }
    
    public func create(
        bookId: String,
        recordData: RecordVO
    ) -> AnyPublisher<RecordInfo, DomainError> {
        networkProvider.request(
            target: RecordAPI.insert(
                userBookId: bookId,
                recordData: recordData
            ),
            type: InsertRecordResponseDTO.self
        )
        .mapError { $0.toDomainError() }
        .debugError(logger: AppLogger.network)
        .map { $0.toRecordInfo() }
        .eraseToAnyPublisher()
    }
    
    public func fetch(
        bookId: String,
        sortType: LibrarySortType,
        page: Int
    ) -> AnyPublisher<(infos: [RecordInfo], hasMore: Bool, totalCount: Int), DomainError> {
        networkProvider.request(
            target: RecordAPI.fetch(
                userBookId: bookId,
                dto: FetchRecordRequestDTO(
                    page: page,
                    sort: sortType
                )
            ),
            type: FetchRecordResponseDTO.self
        )
        .mapError { $0.toDomainError() }
        .debugError(logger: AppLogger.network)
        .map { ($0.readingRecords.map { $0.toRecordInfo() }, !$0.lastPage, $0.totalResults) }
        .eraseToAnyPublisher()
    }
    
    public func findBy(
        id recordId: String
    ) -> AnyPublisher<RecordInfo, DomainError> {
        networkProvider.request(
            target: RecordAPI.detail(userRecordId: recordId),
            type: DetailRecordResponseDTO.self
        )
        .mapError { $0.toDomainError() }
        .debugError(logger: AppLogger.network)
        .map { $0.toRecordInfo() }
        .eraseToAnyPublisher()
    }
}

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
    ) -> AnyPublisher<RecordFetchResult, DomainError> {
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
        .map {
            let emotion: Emotion? = $0.representativeEmotion.flatMap {
                Emotion(rawValue: $0.displayName)
            }
            return RecordFetchResult(
                infos: $0.readingRecords.map { $0.toRecordInfo() },
                hasMore: !$0.lastPage,
                totalCount: $0.totalResults,
                mainEmotion: emotion
            )
        }
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
    
    public func patch(
        recordId: String,
        recordData: RecordVO
    ) -> AnyPublisher<RecordInfo, DomainError> {
        networkProvider.request(
            target: RecordAPI.patch(
                readingRecordId: recordId,
                recordData: recordData
            ),
            type: InsertRecordResponseDTO.self
        )
        .mapError { $0.toDomainError() }
        .debugError(logger: AppLogger.network)
        .map { $0.toRecordInfo() }
        .eraseToAnyPublisher()
    }
    
    public func delete(
        recordId: String
    ) -> AnyPublisher<Void, DomainError> {
        networkProvider.request(
            target: RecordAPI.delete(
                readingRecordId: recordId
            ),
            type: EmptyResponse.self
        )
        .mapError { $0.toDomainError() }
        .debugError(logger: AppLogger.network)
        .map { _ in }
        .eraseToAnyPublisher()
    }
}

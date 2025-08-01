// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

public final class DefaultRecordRepository: RecordRepsitory{
    private let networkProvider: NetworkProvider
    
    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }
    
    public func create(
        bookId: String,
        data: RecordVO
    ) -> AnyPublisher<RecordInfo, Error> {
        networkProvider.request(
            target: RecordAPI.createRecord(
                userBookId: bookId,
                dto: RecordPostDTO(data: data)
            ),
            type: RecordDetailResponseDTO.self
        )
        .mapError { return $0 as Error }
        .debugError(logger: AppLogger.network)
        .map { return $0.toRecordInfo() }
        .eraseToAnyPublisher()
    }
    
}

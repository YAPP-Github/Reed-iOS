// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine

public struct DefaultNotificationRepository: NotificationRepository {
    private let networkProvider: NetworkProvider
    
    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }
    
    public func upsertFCMToken(
        fcmToken: String
    ) -> AnyPublisher<Void, DomainError> {
        networkProvider.request(
            target: UserAPI.upsertFCMToken(fcmToken: fcmToken),
            type: UserProfileResponseDTO.self
        )
        .debugError(logger: AppLogger.network)
        .mapError { $0.toDomainError() }
        .map { _ in }
        .eraseToAnyPublisher()
    }
    
    public func upsertNotificationSettings(
        notificationSettings: Bool
    ) -> AnyPublisher<Bool, DomainError> {
        networkProvider.request(
            target: UserAPI.upsertNotificationSettings(
                notificationEnabled: notificationSettings
            ),
            type: UserProfileResponseDTO.self
        )
        .debugError(logger: AppLogger.network)
        .mapError { $0.toDomainError() }
        .map { $0.notificationEnabled }
        .eraseToAnyPublisher()
    }
}

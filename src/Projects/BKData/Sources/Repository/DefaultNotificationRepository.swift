// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine

public struct DefaultNotificationRepository: NotificationRepository {
    private let networkProvider: NetworkProvider
    private let deviceIDProvider: DeviceIDProvider

    public init(
        networkProvider: NetworkProvider,
        deviceIDProvider: DeviceIDProvider
    ) {
        self.networkProvider = networkProvider
        self.deviceIDProvider = deviceIDProvider
    }
    
    public func upsertFCMToken(
        fcmToken: String
    ) -> AnyPublisher<Void, DomainError> {
        guard let deviceID = deviceIDProvider.deviceID else {
            Log.error("Device ID not available", logger: AppLogger.storage)
            return Fail(error: DomainError.unknown)
                .eraseToAnyPublisher()
        }

        return networkProvider.request(
            target: UserAPI.upsertFCMToken(fcmToken: fcmToken, deviceId: deviceID),
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

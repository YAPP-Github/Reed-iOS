// Copyright © 2025 Booket. All rights reserved

import BKCore
import Combine
import Foundation

public struct DefaultSyncFCMTokenUseCase: SyncFCMTokenUseCase {
    private let pushTokenRepository: PushTokenRepository
    private let notificationRepository: NotificationRepository

    public init(
        pushTokenRepository: PushTokenRepository,
        notificationRepository: NotificationRepository
    ) {
        self.pushTokenRepository = pushTokenRepository
        self.notificationRepository = notificationRepository
    }

    public func execute() -> AnyPublisher<Void, DomainError> {
        guard pushTokenRepository.isSyncNeeded() else {
            return Just(())
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        guard let fcmToken = pushTokenRepository.getFCMToken() else {
            return Just(())
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        return notificationRepository
            .upsertFCMToken(fcmToken: fcmToken)
            .debugError(logger: AppLogger.network)
            .flatMap { _ -> AnyPublisher<Void, DomainError> in
                return self.pushTokenRepository.resetSyncNeeded()
            }
            .eraseToAnyPublisher()
    }
}

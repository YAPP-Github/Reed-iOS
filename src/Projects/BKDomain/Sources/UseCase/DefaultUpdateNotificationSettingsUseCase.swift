// Copyright © 2025 Booket. All rights reserved

import BKCore
import Combine
import Foundation

public struct DefaultUpdateNotificationSettingsUseCase: UpdateNotificationSettingsUseCase {
    private let notificationRepository: NotificationRepository

    public init(
        notificationRepository: NotificationRepository
    ) {
        self.notificationRepository = notificationRepository
    }

    public func execute(isEnabled: Bool) -> AnyPublisher<Bool, DomainError> {
        return notificationRepository
            .upsertNotificationSettings(notificationSettings: isEnabled)
            .debugError(logger: AppLogger.network)
            .mapError { error in
                switch error {
                case .internalServerError:
                    return .internalServerError
                case .unauthorized:
                    return .unauthorized
                default:
                    return .clientError
                }
            }
            .eraseToAnyPublisher()
    }
}

// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol NotificationRepository {
    func upsertFCMToken(
        fcmToken: String
    ) -> AnyPublisher<Void, DomainError>
    
    func upsertNotificationSettings(
        notificationSettings: Bool
    ) -> AnyPublisher<Bool, DomainError>
}

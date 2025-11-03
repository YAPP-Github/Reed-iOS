// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

/// 알림 설정을 서버에 업데이트합니다.
public protocol UpdateNotificationSettingsUseCase {
    func execute(isEnabled: Bool) -> AnyPublisher<Bool, DomainError>
}

// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

/// FCM 토큰이 동기화가 필요한 경우 서버에 업데이트합니다.
/// isSyncNeeded 플래그를 확인하고, 필요시 서버에 전송하며, 성공 시 플래그를 리셋합니다.
public protocol SyncFCMTokenUseCase {
    func execute() -> AnyPublisher<Void, DomainError>
}

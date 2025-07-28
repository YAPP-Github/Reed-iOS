// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

/// 인증 상태를 체크합니다.
/// 내부에 AccessToken이 있는지 확인하고, 서버로 보내 검증합니다.
public protocol AuthStateUseCase {
    func execute() -> AnyPublisher<UserProfile, AuthError>
}

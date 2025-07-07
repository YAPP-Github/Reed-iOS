// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

/// 설정 화면에서 로그아웃 처리 전용 유즈케이스
public protocol LogoutUseCase {
    /// SDK 로그아웃 및 로컬 세션 정리 후,
    /// 필요 시 서버 로그아웃을 수행합니다.
    ///
    /// - Returns: 정상 처리 시 Void
    /// - Failure: `AuthError`
    func execute() -> AnyPublisher<Void, AuthError>
}

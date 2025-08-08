// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

/// 설정 화면에서 회원 탈퇴 처리 전용 유즈케이스
public protocol WithdrawAccountUseCase {
    /// 서버에 회원 탈퇴 요청을 전송하여 계정을 삭제합니다.
    ///
    /// - Returns: 정상 처리 시 Void
    /// - Failure: `AuthError`
    func execute() -> AnyPublisher<Void, AuthError>
}

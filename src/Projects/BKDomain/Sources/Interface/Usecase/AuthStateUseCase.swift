// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

/// 인증 상태를 체크합니다.
/// 단순히 AccessToken 여부를 체크하는 간단한 UseCase로 에러는 방출하지 않습니다.
public protocol AuthStateUseCase {
    func execute() -> AnyPublisher<Bool, Never>
}

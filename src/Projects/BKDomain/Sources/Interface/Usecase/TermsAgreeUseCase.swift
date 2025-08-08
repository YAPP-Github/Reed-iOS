// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

/// 유저가 약관동의를 진행했는지 여부를 서버에 전송합니다.
public protocol TermsAgreeUseCase {
    func execute(_ isAgreed: Bool) -> AnyPublisher<Bool, DomainError>
}

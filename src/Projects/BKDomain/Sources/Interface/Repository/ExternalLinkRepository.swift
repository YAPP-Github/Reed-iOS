// Copyright © 2026 Booket. All rights reserved

import Combine
import Foundation

public protocol ExternalLinkRepository {
    /// 전달받은 URL 문자열을 통해 외부 링크를 실행합니다.
    func open(_ urlString: String) -> AnyPublisher<Bool, Never>
}

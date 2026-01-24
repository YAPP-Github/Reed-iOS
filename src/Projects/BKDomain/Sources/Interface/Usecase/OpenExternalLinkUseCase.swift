// Copyright © 2026 Booket. All rights reserved

import Combine
import Foundation

public protocol OpenExternalLinkUseCase {
    /// 외부 링크를 실행합니다.
    /// appScheme이 있고 실행 가능한 경우 우선 실행하며, 실패 시 urlString을 실행합니다.
    func execute(urlString: String, appScheme: String?) -> AnyPublisher<Bool, Never>
}

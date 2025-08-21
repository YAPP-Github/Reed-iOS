// Copyright © 2025 Booket. All rights reserved

import Combine

/// 앱 버전을 반환합니다.
public protocol AppVersionUseCase {
    func execute() -> AnyPublisher<String, Never>
    func executeRecentVersion() -> AnyPublisher<String, Error>
}

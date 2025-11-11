// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

/// Remote Config에서 앱 버전 정보(최신, 최소)를 가져옵니다.
public protocol FetchRemoteAppVersionUseCase {
    func execute() -> AnyPublisher<RemoteAppVersion, Error>
}

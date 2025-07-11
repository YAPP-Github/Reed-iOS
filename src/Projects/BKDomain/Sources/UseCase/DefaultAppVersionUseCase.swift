// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

public struct DefaultAppVersionUseCase: AppVersionUseCase {
    public func execute() -> AnyPublisher<String, Never> {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-"
        return Just(version).eraseToAnyPublisher()
    }
}

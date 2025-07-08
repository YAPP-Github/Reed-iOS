// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

public protocol URLBuilding {
    func makeURL(target: RequestTarget) -> AnyPublisher<URL, NetworkError>
}

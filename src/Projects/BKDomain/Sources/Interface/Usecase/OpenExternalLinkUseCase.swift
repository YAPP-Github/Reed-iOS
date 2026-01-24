// Copyright © 2026 Booket. All rights reserved

import Combine
import Foundation

public protocol OpenExternalLinkUseCase {
    func execute(url: String) -> AnyPublisher<Bool, Never>
}

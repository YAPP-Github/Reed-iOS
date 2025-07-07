// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

public protocol SocialLoginUseCase {
    func execute() -> AnyPublisher<String, AuthError>
}

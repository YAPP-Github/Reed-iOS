// Copyright © 2025 Booket. All rights reserved

import UIKit
import Combine

public protocol CheckTermsStateUseCase {
    func execute() -> AnyPublisher<Bool, AuthError>
}

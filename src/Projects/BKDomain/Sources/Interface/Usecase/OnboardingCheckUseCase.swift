// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol OnboardingCheckUseCase {
    func execute() -> AnyPublisher<Bool, Never>
}

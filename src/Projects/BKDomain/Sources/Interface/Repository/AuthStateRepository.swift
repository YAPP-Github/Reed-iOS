// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol AuthStateRepository {
    func isLoggedIn() -> AnyPublisher<Bool, Never>
    func validate() -> AnyPublisher<Void, AuthError>
}

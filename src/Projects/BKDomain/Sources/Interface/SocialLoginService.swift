// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

public protocol SocialLoginService: AnyObject {
    var provider: AuthProvider { get }
    
    func login() -> AnyPublisher<String, AuthError>
}

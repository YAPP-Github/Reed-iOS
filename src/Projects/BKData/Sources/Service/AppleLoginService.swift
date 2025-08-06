// Copyright © 2025 Booket. All rights reserved

import AuthenticationServices
import BKDomain
import Combine
import Foundation

public final class AppleLoginService: AnyObject, SocialLoginService {
    public let provider: AuthProvider = .apple
    private let delegateProxy: AppleLoginDelegateProxy
    
    public init() {
        self.delegateProxy = AppleLoginDelegateProxy()
    }
    
    public func login() -> AnyPublisher<SocialLoginToken, AuthError> {
        return delegateProxy.startAuthorization()
    }
}

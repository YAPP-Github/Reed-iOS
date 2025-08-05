// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

public enum AuthAPI {
    case login(
        provider: AuthProvider,
        token: String,
        authorizationCode: String?
    )
    case logout
    case refresh(token: String)
    case me
    case termsAgreement(termsAgreed: Bool)
}

extension AuthAPI: RequestTarget {
    public var baseURL: String {
        return "\(APIConfig.baseURL)/auth"
    }
    
    public var path: String {
        switch self {
        case .login:
            return "/signin"
        case .logout:
            return "/signout"
        case .refresh:
            return "/refresh"
        case .me:
            return "/me"
        case .termsAgreement:
            return "/terms-agreement"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .login, .logout, .refresh:
            return .post
        case .me:
            return .get
        case .termsAgreement:
            return .put
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .login, .refresh, .termsAgreement:
            return [
                "Content-Type": "application/json"
            ]
        case .logout, .me:
            return [:]
        }
    }
    
    public var body: (any Encodable)? {
        switch self {
        case .login(let provider, let token, let authCode):
            return AuthLoginRequestDTO(
                providerType: provider,
                oauthToken: token,
                authorizationCode: authCode
            )
        case .refresh(let token):
            return RefreshRequestDTO(
                refreshToken: token
            )
        case .logout, .me:
            return nil
        case .termsAgreement(let termsAgreed):
            return  TermsAgreementRequestDTO(termsAgreed: termsAgreed)
        }
    }
    
    public var query: [String: Any] {
        switch self {
        case .login, .logout, .refresh, .me, .termsAgreement:
            return [:]
        }
    }
}

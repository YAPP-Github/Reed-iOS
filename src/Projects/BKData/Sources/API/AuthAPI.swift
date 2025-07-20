// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

public enum AuthAPI {
    case login(provider: AuthProvider, token: String)
    case logout
    case refresh(token: String)
    case me
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
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .login, .logout, .refresh:
            return .post
        case .me:
            return .get
        }
    }
    
    public var headers: [String: String] {
        switch self {
        case .login, .refresh:
            return [
                "Content-Type": "application/json"
            ]
        case .logout, .me:
            return [:]
        }
    }
    
    public var body: (any Encodable)? {
        switch self {
        case .login(let provider, let token):
            return AuthLoginRequestDTO(
                providerType: provider,
                oauthToken: token
            )
        case .refresh(let token):
            return RefreshRequestDTO(
                refreshToken: token
            )
        case .logout, .me:
            return nil
        }
    }
    
    public var query: [String: Any] {
        switch self {
        case .login, .logout, .refresh, .me:
            return [:]
        }
    }
}

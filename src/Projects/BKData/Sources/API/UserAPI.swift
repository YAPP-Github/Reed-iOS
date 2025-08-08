// Copyright © 2025 Booket. All rights reserved

import Foundation

enum UserAPI {
    case me
    case termsAgreement(termsAgreed: Bool)
}

extension UserAPI: RequestTarget {
    var baseURL: String {
        return "\(APIConfig.baseURL)/users/me"
    }
    
    var path: String {
        switch self {
        case .me:
            return ""
        case .termsAgreement:
            return "/terms-agreement"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .me:
            return .get
        case .termsAgreement:
            return .put
        }
    }
    
    var headers: [String: String] {
        switch self {
        case .termsAgreement:
            return [
                "Content-Type": "application/json"
            ]
        case .me:
            return [:]
        }
    }
    
    var body: Encodable? {
        switch self {
        case .termsAgreement(let termsAgreed):
            return TermsAgreementRequestDTO(termsAgreed: termsAgreed)
        case .me:
            return nil
        }
    }
    
    var query: [String: Any] {
        return [:]
    }
}

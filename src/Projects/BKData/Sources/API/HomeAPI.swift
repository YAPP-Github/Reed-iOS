// Copyright © 2025 Booket. All rights reserved

import BKDomain

enum HomeAPI {
    case fetch
}

extension HomeAPI: RequestTarget {
    var baseURL: String {
        return "\(APIConfig.baseURL)/home"
    }
    
    var path: String {
        switch self {
        case .fetch:
            return ""
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetch:
            return .get
        }
    }
    
    var headers: [String: String] {
        switch self {
        case .fetch:
            return [:]
        }
    }
    
    var body: (any Encodable)? {
        return nil
    }
    
    var query: [String: Any] {
        return [:]
    }
}

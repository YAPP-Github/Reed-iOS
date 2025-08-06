// Copyright © 2025 Booket. All rights reserved

enum SeedAPI {
    case stats
}

extension SeedAPI: RequestTarget {
    var baseURL: String {
        return "\(APIConfig.baseURL)/seeds"
    }
    
    var path: String {
        switch self {
        case .stats:
            return "/stats"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .stats:
            return .get
        }
    }
    
    var headers: [String: String] {
        return [:]
    }
    
    var body: Encodable? {
        return nil
    }
    
    var query: [String: Any] {
        return [:]
    }
}

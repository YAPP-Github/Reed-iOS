// Copyright © 2025 Booket. All rights reserved

import Foundation

enum EmotionAPI {
    case fetchEmotions
}

extension EmotionAPI: RequestTarget {
    var baseURL: String {
        return "\(APIConfig.baseURLv2)/emotions"
    }

    var path: String {
        switch self {
        case .fetchEmotions:
            return ""
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchEmotions:
            return .get
        }
    }

    var headers: [String: String] {
        return [
            "Content-Type": "application/json"
        ]
    }

    var body: Encodable? {
        return nil
    }

    var query: [String: Any] {
        return [:]
    }
}

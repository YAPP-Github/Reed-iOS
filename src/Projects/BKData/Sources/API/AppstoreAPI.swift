// Copyright © 2025 Booket. All rights reserved

import Foundation

struct AppStoreResponseDTO: Decodable {
    let results: [AppInfo]
    
    struct AppInfo: Decodable {
        let version: String
    }
}

enum AppstoreAPI {
    case lookup(appId: String)
}

extension AppstoreAPI: RequestTarget {
    var baseURL: String {
        return "https://itunes.apple.com/kr"
    }

    var path: String {
        switch self {
        case .lookup:
            return "/lookup"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .lookup:
            return .get
        }
    }

    var headers: [String : String] {
        return [:]
    }

    var body: (any Encodable)? {
        return nil
    }

    var query: [String: Any] {
        switch self {
        case .lookup(let appId):
            return ["id": appId]
        }
    }

}

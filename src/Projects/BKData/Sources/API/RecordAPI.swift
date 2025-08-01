// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

enum RecordAPI {
    case createRecord(userBookId: String, dto: RecordPostDTO)
    case readRecord(userBookId: String, dto: Data)
}

extension RecordAPI: RequestTarget {
    var baseURL: String {
        return "\(APIConfig.baseURL)/reading-records"
    }

    var path: String {
        switch self {
        case .createRecord(let userBookId, _):
            return "\(userBookId)"
        case .readRecord(let userBookId, _):
            return "\(userBookId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createRecord:
            return .post
        case .readRecord:
            return .get
        }
    }

    var headers: [String : String] {
        switch self {
        default:
            return [
                "Content-Type": "application/json"
            ]
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .createRecord(_, let dto):
            return dto
        case .readRecord:
            return nil
        }
    }

    var query: [String : Any] {
        switch self {
        case .createRecord:
            return [:]
        case .readRecord(_, let dto):
            return [:]
        }
    }
    
}

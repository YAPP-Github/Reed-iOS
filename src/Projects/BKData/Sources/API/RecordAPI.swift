// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

enum RecordAPI {
    case insert(userBookId: String, recordData: RecordVO)
    case fetch(userBookId: String, dto: FetchRecordRequestDTO)
}

extension RecordAPI: RequestTarget {
    var baseURL: String {
        return "\(APIConfig.baseURL)/reading-records"
    }

    var path: String {
        switch self {
        case .insert(let userBookId, _):
            return "/\(userBookId)"
        case .fetch(let userBookId, _):
            return "/\(userBookId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .insert:
            return .post
        case .fetch:
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
        case .insert(_, let data):
            return InsertRecordRequestDTO(data: data)
        case .fetch:
            return nil
        }
    }

    var query: [String: Any] {
        switch self {
        case .insert:
            return [:]
        case .fetch(_, let dto):
            return dto.toDictionary()
        }
    }
    
}

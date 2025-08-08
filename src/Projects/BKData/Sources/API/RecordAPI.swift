// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

enum RecordAPI {
    case insert(userBookId: String, recordData: RecordVO)
    case fetch(userBookId: String, dto: FetchRecordRequestDTO)
    case detail(userRecordId: String)
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
        case .detail(let userRecordId):
            return "/\(userRecordId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .insert:
            return .post
        case .fetch, .detail:
            return .get
        }
    }

    var headers: [String: String] {
        switch self {
        default:
            return [
                "Content-Type": "application/json"
            ]
        }
    }

    var body: Encodable? {
        switch self {
        case .insert(_, let data):
            return InsertRecordRequestDTO(data: data)
        case .fetch, .detail:
            return nil
        }
    }

    var query: [String: Any] {
        switch self {
        case .insert:
            return [:]
        case .fetch(_, let dto):
            return dto.toDictionary()
        case .detail(let isbn):
            return BookDetailRequestDTO(isbn: isbn).toDictionary()
        }
    }
    
}

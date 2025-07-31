// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

public enum RecordAPI {
    case createRecord(userBookId: String, dto: Data)
    case readRecord(userBookId: String, dto: Data)
}

extension RecordAPI: RequestTarget {
    public var baseURL: String {
        return "\(APIConfig.baseURL)/reading-records"
    }

    public var path: String {
        switch self {
        case .createRecord(let userBookId, _):
            return "\(userBookId)"
        case .readRecord(let userBookId, _):
            return "\(userBookId)"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .createRecord:
            return .post
        case .readRecord:
            return .get
        }
    }

    public var headers: [String : String] {
        switch self {
        default:
            return [
                "Content-Type": "application/json"
            ]
        }
    }

    public var body: (any Encodable)? {
        switch self {
        case .createRecord(_, let dto):
            return dto
        case .readRecord:
            return nil
        }
    }

    public var query: [String : Any] {
        switch self {
        case .createRecord:
            return [:]
        case .readRecord(_, let dto):
            return [:]
        }
    }
    
}

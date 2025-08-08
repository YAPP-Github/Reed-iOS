// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

enum BookAPI {
    case detail(isbn: String)
    case myLibrary(parameter: LibraryRequestDTO)
    case search(dto: SearchBookRequestDTO)
    case upsert(dto: UserBookRegisterRequestDTO)
}

extension BookAPI: RequestTarget {
    var baseURL: String {
        return "\(APIConfig.baseURL)/books"
    }
    
    var path: String {
        switch self {
        case .detail:
            return "/detail"
        case .myLibrary:
            return "/my-library"
        case .search:
            return "/search"
        case .upsert:
            return "/upsert"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .upsert:
            return .put
        case .detail, .myLibrary, .search:
            return .get
        }
    }
    
    var headers: [String: String] {
        switch self {
        case .upsert:
            return [
                "Content-Type": "application/json"
            ]
        case .detail, .myLibrary, .search:
            return [:]
        }
    }
    
    var body: Encodable? {
        switch self {
        case .detail, .myLibrary, .search:
            return nil
        case .upsert(let dto):
            return dto
        }
    }
    
    var query: [String: Any] {
        switch self {
        case .detail(let isbn):
            return BookDetailRequestDTO(isbn13: isbn).toDictionary()
        case .myLibrary(let parameter):
            return parameter.dictionary
        case .search(let dto):
            return dto.dictionary
        case .upsert:
            return [:]
        }
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKDomain

public enum NetworkError: Error {
    case badRequest
    case invalidURL
    case invalidResponse
    case unauthorized
    case internalServerError
    case timeout
    case retryTrigger
    case retryFailed
    case unknown
    
    func toDomainError() -> DomainError {
        switch self {
        case .badRequest, .invalidResponse, .invalidURL:
            return .clientError
        case .unauthorized, .retryFailed, .retryTrigger:
            return .unauthorized
        case .timeout:
            return .timeout
        case .internalServerError, .unknown:
            return .internalServerError
        }
    }
}

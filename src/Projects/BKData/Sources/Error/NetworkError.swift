// Copyright © 2025 Booket. All rights reserved

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
}

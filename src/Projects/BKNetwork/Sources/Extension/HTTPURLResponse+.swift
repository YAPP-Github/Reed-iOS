// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import Foundation
import OSLog

extension HTTPURLResponse {
    func validate(_ data: Data) throws {
        switch statusCode {
        case 200...299:
            return
        case 400:
            throw NetworkError.badRequest
        case 401:
            throw NetworkError.unauthorized
        case 500...599:
            throw NetworkError.internalServerError
        default:
            Log.error(
                """
                status code: \(statusCode)
                body: \(String(data: data, encoding: .utf8) ?? "none")"
                """,
                logger: AppLogger.network
            )
            throw NetworkError.invalidResponse
        }
    }
}

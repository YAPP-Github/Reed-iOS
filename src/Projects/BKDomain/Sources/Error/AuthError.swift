// Copyright © 2025 Booket. All rights reserved

import Foundation

/// 인증 관련 에러
public enum AuthError: Error {
    case sdkError(message: String)    // SDK 호출 중 에러
    case serverError(message: String) // 서버 호출 중 에러
    case missingToken                 // 토큰이 없을 때
    case unknown
}


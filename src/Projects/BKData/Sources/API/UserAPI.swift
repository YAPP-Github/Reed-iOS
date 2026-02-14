// Copyright © 2025 Booket. All rights reserved

import Foundation

enum UserAPI {
    case me
    case termsAgreement(termsAgreed: Bool)
    case upsertFCMToken(fcmToken: String, deviceId: String)
    case upsertNotificationSettings(notificationEnabled: Bool)
}

extension UserAPI: RequestTarget {
    var baseURL: String {
        return "\(APIConfig.baseURLv1)/users/me"
    }
    
    var path: String {
        switch self {
        case .me:
            return ""
        case .termsAgreement:
            return "/terms-agreement"
        case .upsertFCMToken:
            return "/fcm-token"
        case .upsertNotificationSettings:
            return "/notification-settings"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .me:
            return .get
        case .termsAgreement, .upsertFCMToken, .upsertNotificationSettings:
            return .put
        }
    }
    
    var headers: [String: String] {
        switch self {
        case .termsAgreement, .upsertFCMToken, .upsertNotificationSettings:
            return [
                "Content-Type": "application/json"
            ]
        case .me:
            return [:]
        }
    }
    
    var body: Encodable? {
        switch self {
        case .termsAgreement(let termsAgreed):
            return TermsAgreementRequestDTO(termsAgreed: termsAgreed)
        case .upsertFCMToken(let fcmToken, let deviceId):
            return UpsertFCMTokenRequestDTO(fcmToken: fcmToken, deviceId: deviceId)
        case .upsertNotificationSettings(let notificationEnabled):
            return NotificationStatusRequestDTO(notificationEnabled: notificationEnabled)
        case .me:
            return nil
        }
    }
    
    var query: [String: Any] {
        return [:]
    }
}

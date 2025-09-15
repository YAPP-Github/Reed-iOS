// Copyright © 2025 Booket. All rights reserved

import Firebase
import FirebaseAnalytics
import Foundation

/// 스크린 로깅 기능을 위한 프로토콜
public protocol ScreenLoggable {
    var screenName: String { get }
}

/// 프로토콜의 기본 구현을 제공하는 Extension
extension ScreenLoggable where Self: UIViewController {
    public func logScreenView(name: String? = nil) {
        if let name = name {
            Analytics.logEvent(
                name,
                parameters: [
                    AnalyticsParameterScreenName: name,
                    AnalyticsParameterScreenClass: String(describing: type(of: self))
                ]
            )
        } else {
            Analytics.logEvent(
                screenName,
                parameters: [
                    AnalyticsParameterScreenName: screenName,
                    AnalyticsParameterScreenClass: String(describing: type(of: self))
                ]
            )
        }
    }
}

extension ScreenLoggable {
    public func logGoogleAnalytics(name: String? = nil) {
        if let name = name {
            Analytics.logEvent(
                name,
                parameters: [
                    AnalyticsParameterScreenName: name,
                    AnalyticsParameterScreenClass: String(describing: type(of: self))
                ]
            )
        } else {
            Analytics.logEvent(
                screenName,
                parameters: [
                    AnalyticsParameterScreenName: screenName,
                    AnalyticsParameterScreenClass: String(describing: type(of: self))
                ]
            )
        }
    }
}

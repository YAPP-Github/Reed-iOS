// Copyright © 2025 Booket. All rights reserved

import FirebaseAnalytics
import FirebaseCore
import UIKit

public final class GAManager {
    public static func configureAnalytics() {
        #if DEBUG
            Analytics.setAnalyticsCollectionEnabled(false)
            Analytics.setUserProperty("true", forName: "debug_mode")
        #else
            Analytics.setAnalyticsCollectionEnabled(true)
            Analytics.setUserProperty("false", forName: "debug_mode")
        #endif
        
        // 시뮬레이터 환경 체크
        #if targetEnvironment(simulator)
            Analytics.setUserProperty("true", forName: "simulator")
        #else
            Analytics.setUserProperty("false", forName: "simulator")
        #endif
        
        // 앱 버전 정보 설정
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            Analytics.setUserProperty("\(version)(\(build))", forName: "app_version")
        }
        
        Analytics.setConsent([
          .adStorage: .denied,
          .adUserData: .denied,
          .adPersonalization: .denied
        ])
        
        // 기기 정보 설정
        setDeviceInfo()
        
        // 국가/지역 정보 설정
        setLocationInfo()
    }
    
    private static func setDeviceInfo() {
        Analytics.setDefaultEventParameters([
            "device_model": UIDevice.current.model,
            "ios_version": UIDevice.current.systemVersion,
            "device_identifier": getDeviceIdentifier(),
            "screen_size": "\(Int(UIScreen.main.bounds.width))x\(Int(UIScreen.main.bounds.height))",
            "screen_scale": "\(UIScreen.main.scale)"
        ])
    }
    
    private static func setLocationInfo() {
        let currentLocale = Locale.current
        var params: [String: Any] = [:]

        // 국가 코드
        if let countryCode = currentLocale.region?.identifier {
            params["country_code"] = countryCode
        }

        // 언어 코드
        if let languageCode = currentLocale.language.languageCode?.identifier {
            params["language_code"] = languageCode
        }

        // 전체 로케일
        params["locale"] = currentLocale.identifier

        // 국가 이름
        if let countryCode = currentLocale.region?.identifier,
           let countryName = currentLocale.localizedString(forRegionCode: countryCode) {
            params["country_name"] = countryName
        }

        // 타임존
        params["time_zone"] = TimeZone.current.identifier

        Analytics.setDefaultEventParameters(params)
    }
    
    private static func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

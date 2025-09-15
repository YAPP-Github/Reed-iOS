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
        
        // 기기 정보 설정
        setDeviceInfo()
        
        // 국가/지역 정보 설정
        setLocationInfo()
    }
    
    private static func setDeviceInfo() {
        // 기기 모델
        let deviceModel = UIDevice.current.model
        Analytics.setUserProperty(deviceModel, forName: "device_model")
        
        // iOS 버전
        let systemVersion = UIDevice.current.systemVersion
        Analytics.setUserProperty(systemVersion, forName: "ios_version")
        
        // 정확한 기기 식별자
        let deviceIdentifier = getDeviceIdentifier()
        Analytics.setUserProperty(deviceIdentifier, forName: "device_identifier")
        
        // 화면 크기
        let screenSize = UIScreen.main.bounds.size
        let screenSizeString = "\(Int(screenSize.width))x\(Int(screenSize.height))"
        Analytics.setUserProperty(screenSizeString, forName: "screen_size")
        
        // 화면 스케일
        let screenScale = UIScreen.main.scale
        Analytics.setUserProperty("\(screenScale)", forName: "screen_scale")
    }
    
    private static func setLocationInfo() {
        let currentLocale = Locale.current
        
        // 국가 코드
        if let countryCode = currentLocale.region?.identifier {
            Analytics.setUserProperty(countryCode, forName: "country_code")
        }
        
        // 언어 코드
        if let languageCode = currentLocale.language.languageCode?.identifier {
            Analytics.setUserProperty(languageCode, forName: "language_code")
        }
        
        // 전체 로케일
        let localeIdentifier = currentLocale.identifier
        Analytics.setUserProperty(localeIdentifier, forName: "locale")
        
        // 국가 이름
        if let countryCode = currentLocale.region?.identifier,
           let countryName = currentLocale.localizedString(forRegionCode: countryCode) {
            Analytics.setUserProperty(countryName, forName: "country_name")
        }
        
        // 타임존
        let timeZone = TimeZone.current.identifier
        Analytics.setUserProperty(timeZone, forName: "time_zone")
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

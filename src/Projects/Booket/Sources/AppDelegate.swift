// Copyright © 2025 Booket. All rights reserved

import BKData
import KakaoSDKCommon
#if DEBUG
import Pulse
import PulseProxy
#endif
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard let kakaoAPIkey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            fatalError("Error: KAKAO_NATIVE_APP_KEY not found in Info.plist")
        }
#if DEBUG
        NetworkLogger.enableProxy()
#endif
        KakaoSDK.initSDK(appKey: kakaoAPIkey)
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}

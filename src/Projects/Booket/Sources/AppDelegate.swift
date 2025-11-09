// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import BKStorage
import Combine
import Firebase
import FirebaseMessaging
import KakaoSDKCommon
#if DEBUG
import Pulse
import PulseProxy
#endif
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private var cancellables = Set<AnyCancellable>()
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard let kakaoAPIkey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            fatalError("Error: KAKAO_NATIVE_APP_KEY not found in Info.plist")
        }
#if DEBUG
        NetworkLogger.enableProxy()
        LoggingBootstrap.install()
#endif
        KakaoSDK.initSDK(appKey: kakaoAPIkey)
        FirebaseApp.configure()

        GAManager.configureAnalytics()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // 앱 실행 시 DeviceID 생성 (없으면)
        // 키체인에 저장되므로 앱 삭제 후 재설치해도 유지됨
        KeychainDeviceIDStore.shared.getOrCreate()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        AppLogger.auth.error("Failed to get or create device ID: \(error)")
                    }
                },
                receiveValue: { deviceID in
                    AppLogger.auth.info("Device ID ready: \(deviceID)")
                }
            )
            .store(in: &cancellables)
        
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
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    /// 정확히 이 시점에서 FCM Token이 생성됩니다.
    /// FCM Token이 재발급 되는 시점도 해당 시점입니다.
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let token = fcmToken else { return }

        KeychainPushTokenStore.shared.save(fcmToken: token)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        AppLogger.auth.error("Failed to save FCM token: \(error)")
                    }
                },
                receiveValue: { _ in
                    AppLogger.auth.info("FCM token saved successfully")
                }
            )
            .store(in: &cancellables)
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {}

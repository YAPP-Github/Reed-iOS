// Copyright © 2025 Booket. All rights reserved

public protocol PushTokenProvider {
    var fcmToken: String? { get }
    var isSyncNeeded: Bool? { get }
    func clearCache()
}

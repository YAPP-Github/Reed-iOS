// Copyright © 2025 Booket. All rights reserved

/// 세션이 만료되었을 때(토큰 만료)의 후속 조치를 위한 프로토콜입니다.
/// MainFlow 등 Flow의 시작점에서만 사용되어야 합니다.
protocol SessionExpirationHandling: AnyObject {
    func handleSessionExpired()
}

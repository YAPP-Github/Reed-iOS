// Copyright © 2025 Booket. All rights reserved

/// 화면에서 인증이 필요한 네트워크를 사용하는 경우,
/// 토큰 만료시 최상단 Coordinator에게 알리기 위한 프로토콜입니다.
protocol SessionExpirationNotifying: AnyObject {}

extension SessionExpirationNotifying where Self: Coordinator {
    func notifyParentSessionExpired() {
        firstAncestor(ofType: SessionExpirationHandling.self)?
            .handleSessionExpired()
    }
}

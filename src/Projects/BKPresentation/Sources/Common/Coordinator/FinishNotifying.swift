// Copyright © 2025 Booket. All rights reserved

/// Coordinator가 자신의 Flow를 끝났음을 알릴 때, 상위 컨텍스트에게 알리기 위한 장치입니다.
///
/// ### Example
/// ```swift
/// final class AppCoordinator: Coordinator {
///     func start() {
///         let onboarding = ADOnboardingCoordinator(...)
///         onboarding.onFinish = { [weak self] in
///             self?.startMainFlow()
///         }
///         onboarding.start()
///     }
/// }
/// ```
protocol FinishNotifying: AnyObject {
    var onFinish: (() -> Void)? { get set }
}

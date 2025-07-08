// Copyright © 2025 Booket. All rights reserved

/// 각 계층에서 발생하는 의존성을 명시적으로 나누기 위한 인터페이스입니다.
///
/// ### Example
/// ```swift
/// // 각 계층에서
/// public struct DataAssembly: Assembly { ... }
/// public struct DomainAssembly: Assembly { ... }
/// // SceneDelegate에서
/// DIContainer.shared.assemble([DataAssembly(), DomainAssembly()])
/// ```
public protocol Assembly {
    func assemble(container: DIContainer)
}

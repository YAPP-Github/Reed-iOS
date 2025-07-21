// Copyright © 2025 Booket. All rights reserved

import Foundation

typealias DependencyInjectable = DependencyResolver & DependencyAssembler

public final class DIContainer: DependencyInjectable {
    // MARK: - Properties
    public static let shared = DIContainer()
    
    private var services: [String: DependencyContainerClosure] = [:]
    private var instances: [String: Any] = [:]
    
    private let resolveLock = NSRecursiveLock()
    private var resolving: Set<String> = []
    
    // MARK: - Methods
    /// SceneDelegate에서 사용합니다. 자세한 설명은 Assembly의 Docc을 참고해주세요.
    public func assemble(_ assemblies: [any Assembly]) {
        assemblies.forEach { $0.assemble(container: self) }
    }
    
    /// 여러 스레드에서 `register(_:)`가 실행되면 공유 자원에 대한 문제가 발생할 수 있습니다.
    /// 즉, `register(_:)`는 thread-safe 하지 않은 메소드입니다. 사용시 주의 바랍니다.
    public func register<T>(
        type: T.Type,
        name: String? = nil,
        scope: ContainerScope = .transient,
        containerClosure: @escaping DependencyContainerClosure
    ) {
        let key = "\(name ?? "Default")_\(type)"
        services[key] = { container in
            switch scope {
            case .transient:
                return containerClosure(container)
            case .singleton:
                if let existingInstance = self.instances[key] {
                    return existingInstance
                } else {
                    let instances = containerClosure(container)
                    self.instances[key] = instances
                    return instances
                }
            }
        }
    }
    
    public func resolve<T>(
        type: T.Type,
        name: String? = nil
    ) -> T? {
        let key = "\(name ?? "Default")_\(type)"
        
        resolveLock.lock()
        if resolving.contains(key) {
            fatalError("\(#file) - \(#line): \(#function) - \(type) circular dependency detected")
        }
        resolving.insert(key)
        resolveLock.unlock()
        
        defer {
            resolveLock.lock()
            resolving.remove(key)
            resolveLock.unlock()
        }
        
        guard let service = services[key]?(self) as? T else { return nil }
        return service
    }
    
    /// `@Autowired`를 사용하지 않는 경우, 편하게 `resolve(_:)`를 사용하기 위한 유틸리티 메소드입니다.
    public func resolveOrFatal<T>(
        type: T.Type,
        name: String? = nil
    ) -> T {
        guard let resolved = resolve(type: T.self, name: name) else {
            fatalError("\(#file) - \(#line): \(#function) - resolved failed for \(T.self)")
        }
        return resolved
    }
}

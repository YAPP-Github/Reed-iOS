// Copyright © 2025 Booket. All rights reserved

/// `@Autowired`를 지연 방식으로 만든 구현체입니다.
/// 
@propertyWrapper
public struct LazyAutowired<T> {
    private var cached: T?
    private let name: String?

    public init(name: String? = nil) {
        self.name = name
    }

    public var wrappedValue: T {
        mutating get {
            if let cached = cached {
                return cached
            }
            guard let resolved = DIContainer.shared.resolve(type: T.self, name: name) else {
                fatalError("\(#file) - \(#line): \(#function) - resolved failed for \(T.self) - with \(name ?? "none")")
            }
            cached = resolved
            return resolved
        }
    }
}

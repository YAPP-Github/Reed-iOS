// Copyright © 2025 Booket. All rights reserved

/// Assemble을 편리하게 해주는 도구입니다.
///
/// Coordinator에서 번거롭게 DIContainer를 호출하지 않도록 작업을 돕습니다.
/// 주의할 점으로는, `resolve(_:)`가 실패하는 경우 crash가 발생하므로, `register(_:)`를 꼼꼼히 할 필요가 있습니다.
///
/// ### Example
/// ```swift
/// /// In Coordinator
/// func createMyViewController() -> MYViewController {
///     @Autowired var usecase: MyUseCase
///     let viewmodel = MyViewModel(usecase: usecase)
///     return MyViewController(viewmodel: viewmodel)
/// }
/// ```
@propertyWrapper
public struct Autowired<T> {
    private var service: T
    
    public init(name: String? = nil) {
        guard let resolved = DIContainer.shared.resolve(type: T.self, name: name) else {
            fatalError("\(#file) - \(#line): \(#function) - resolved failed for \(T.self) - with \(name ?? "none")")
        }
        self.service = resolved
    }
    
    public var wrappedValue: T {
        return service
    }
}

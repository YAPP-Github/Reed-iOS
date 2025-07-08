// Copyright © 2025 Booket. All rights reserved

/// Assemble을 편리하게 해주는 도구입니다.
///
/// Coordinator에서 번거롭게 DIContainer를 호출하지 않도록 작업을 돕습니다.
/// 주의할 점으로는, `resolve(_:)`가 실패하는 경우 crash가 발생하므로, `register(_:)`를 꼼꼼히 할 필요가 있습니다.
///
/// ### Example
/// ```swift
/// /// In ViewModel
/// @Autowired(name: "apple") private var appleLoginUseCase: SocialLoginUseCase
/// @Autowired(name: "kakao") private var kakaoLoginUseCase: SocialLoginUseCase
/// @Autowired private var socialTokenAuthUseCase: SocialTokenAuthUseCase
/// ```
///
/// ### 활용 방법
/// ViewModel을 제외한 모든 계층에서는 `Assembly`에서 `@Autowired`로 주입합니다.
/// Data, Domain 등의 계층에서는 테스트가 필수불가결적이므로 생성자 주입을 통한 DI를 활용해주세요.
/// 단, ViewModel의 경우에는 편리하게 `@Autowired` 주입을 추천드립니다.
/// `Coordinator`에서의 불필요한 라인을 줄일 수 있습니다.
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

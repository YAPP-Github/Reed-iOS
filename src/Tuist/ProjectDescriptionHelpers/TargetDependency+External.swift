import ProjectDescription

public enum External: String {
    case KakaoSDKCommon
    case KakaoSDKAuth
    case KakaoSDKUser
    
    case KakaoSDKShare
    case KakaoSDKTalk
    case Lottie
    case Kingfisher
    case SnapKit
    case Swinject
    case FittedSheets
    case Then
    
    case Nimble
    case Quick
}

extension TargetDependency {
    public static func external(dependency: External) -> TargetDependency {
        .external(name: dependency.rawValue, condition: .when([.ios]))
    }
}

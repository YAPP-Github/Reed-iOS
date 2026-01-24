// Copyright © 2026 Booket. All rights reserved

import Foundation

private final class PresentationBundleToken {}

public enum URLConstants {
    private static let bundle = Bundle(for: PresentationBundleToken.self)
    
    private static let kakaoAccount: String = {
        guard let value = bundle.object(forInfoDictionaryKey: "KAKAO_ACCOUNT") as? String else {
            fatalError("Can't load KAKAO_ACCOUNT")
        }
        return value
    }()
    
    public static let kakaoAppScheme = "kakaoplus://plusfriend/home/\(kakaoAccount)"
    public static let kakaoChatURL = "https://pf.kakao.com/\(kakaoAccount)/chat"
}

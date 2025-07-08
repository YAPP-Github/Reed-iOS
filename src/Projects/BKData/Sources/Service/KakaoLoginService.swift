// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine
import Foundation
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

/// 카카오 SDK 로그인 과정을 추상화한 서비스 구현
/// 앱 설치 여부에 따라 앱 로그인 또는 계정 로그인을 수행하고,
/// 발급된 accessToken만 방출합니다.
public final class KakaoLoginService: AnyObject, SocialLoginService {
    /// 이 서비스가 담당할 소셜 공급자
    public let provider: AuthProvider

    /// Kakao SDK의 UserApi 인터페이스 추상화
    private let kakaoAPI: KakaoUserAPIProtocol
    
    /// - Parameters:
    ///   - provider: `.kakao` 고정
    ///   - kakaoAPI: SDK 호출을 추상화한 프로토콜 구현체
    public init(
        provider: AuthProvider = .kakao,
        kakaoAPI: KakaoUserAPIProtocol = UserApi.shared
    ) {
        self.provider = provider
        self.kakaoAPI = kakaoAPI
    }

    /// 카카오 로그인 실행
    /// - Returns: accessToken을 방출하는 퍼블리셔 또는 에러
    public func login() -> AnyPublisher<String, AuthError> {
        if kakaoAPI.isLoginWithTalkAvailable() {
            return loginWithApp()
        } else {
            return loginWithAccount()
        }
    }
}

// MARK: - Private functions
private extension KakaoLoginService {
    /// 카카오톡 앱을 이용한 로그인
    /// - Returns: accessToken을 방출하는 퍼블리셔 또는 에러
    func loginWithApp() -> AnyPublisher<String, AuthError> {
        Future<String, AuthError> { [kakaoAPI] promise in
            kakaoAPI.loginWithKakaoTalk(
                launchMethod: .UniversalLink,
                channelPublicIds: nil,
                serviceTerms: nil,
                nonce: nil
            ) { token, error in
                if let sdkError = error {
                    promise(.failure(.sdkError(message: sdkError.localizedDescription)))
                } else if let access = token?.accessToken {
                    promise(.success(access))
                } else {
                    promise(.failure(.missingToken))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 카카오 계정을 이용한 로그인
    /// - Returns: accessToken을 방출하는 퍼블리셔 또는 에러
    func loginWithAccount() -> AnyPublisher<String, AuthError> {
        Future<String, AuthError> { [kakaoAPI] promise in
            kakaoAPI.loginWithKakaoAccount(
                prompts: nil,
                channelPublicIds: nil,
                serviceTerms: nil,
                nonce: nil
            ) { token, error in
                if let sdkError = error {
                    promise(.failure(.sdkError(message: sdkError.localizedDescription)))
                } else if let access = token?.accessToken {
                    promise(.success(access))
                } else {
                    promise(.failure(.missingToken))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

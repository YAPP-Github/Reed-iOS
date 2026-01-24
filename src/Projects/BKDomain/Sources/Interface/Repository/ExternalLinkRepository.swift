// Copyright © 2026 Booket. All rights reserved

import Combine
import Foundation

/// 외부 시스템(앱 스킴 또는 웹 브라우저)으로 링크를 연결하고 상태를 확인하는 인터페이스입니다.
public protocol ExternalLinkRepository {
    
    /// 전달받은 URL 문자열이 현재 시스템에서 실행 가능한지 여부를 확인합니다.
    ///
    /// - Parameter urlString: 확인할 대상 URL 문자열 (예: "kakaoplus://...", "https://...")
    /// - Returns: 실행 가능 여부 (true: 실행 가능, false: 실행 불가 또는 스킴 미등록)
    func canOpen(_ urlString: String) -> Bool
    
    /// 전달받은 URL 문자열을 통해 외부 링크를 실행합니다.
    ///
    /// - Parameter urlString: 실행할 대상 URL 문자열
    /// - Returns: 실행 성공 여부를 전달하는 Publisher (true: 실행 성공, false: 실행 실패)
    func open(_ urlString: String) -> AnyPublisher<Bool, Never>
}

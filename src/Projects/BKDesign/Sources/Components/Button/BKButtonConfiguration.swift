// Copyright © 2025 Booket. All rights reserved

import UIKit

/// `BKButton`에 적용할 외부 구성 정보를 담는 구조체입니다.
///
/// 버튼 스타일, 크기, 타이틀, 아이콘, 사용 가능 상태 등을 통합 관리하며
/// 설정을 체이닝 방식으로 손쉽게 조합할 수 있습니다.
public struct BKButtonConfiguration {

    /// 버튼 스타일 (기본값: `.primary`)
    var style: BKButtonStyle

    /// 버튼 사이즈 (기본값: `.medium`)
    var size: BKButtonSize

    /// 버튼 타이틀 텍스트
    var title: String?

    /// 왼쪽에 표시할 아이콘
    var leftIcon: UIImage?

    /// 오른쪽에 표시할 아이콘
    var rightIcon: UIImage?

    /// 버튼 활성화 상태 (기본값: `true`)
    var isEnabled: Bool

    /// 가로로 꽉 차는지 여부 (기본값: `false`)
    var isFullWidth: Bool
    
    var hasStroke: Bool

    /// 초기화 메서드
    ///
    /// - Parameters:
    ///   - style: 버튼 스타일
    ///   - size: 버튼 크기
    ///   - title: 버튼 텍스트
    ///   - leftIcon: 좌측 아이콘 이미지
    ///   - rightIcon: 우측 아이콘 이미지
    ///   - isEnabled: 사용 가능 여부
    ///   - isFullWidth: 가로 꽉 채우기 여부
    public init(
        style: BKButtonStyle = .primary,
        size: BKButtonSize = .medium,
        title: String? = nil,
        leftIcon: UIImage? = nil,
        rightIcon: UIImage? = nil,
        isEnabled: Bool = true,
        isFullWidth: Bool = false
    ) {
        self.style = style
        self.size = size
        self.title = title
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.isEnabled = isEnabled
        self.isFullWidth = isFullWidth
        self.hasStroke = style == .stroke ? true : false
    }

    // MARK: - Immutable Modifier Helpers

    /// 스타일을 변경한 새로운 설정 반환
    public func withStyle(_ style: BKButtonStyle) -> Self {
        var config = self
        config.style = style
        return config
    }

    /// 사이즈를 변경한 새로운 설정 반환
    public func withSize(_ size: BKButtonSize) -> Self {
        var config = self
        config.size = size
        return config
    }

    /// 타이틀을 변경한 새로운 설정 반환
    public func withTitle(_ title: String?) -> Self {
        var config = self
        config.title = title
        return config
    }

    /// 왼쪽 아이콘을 변경한 새로운 설정 반환
    public func withLeftIcon(_ icon: UIImage?) -> Self {
        var config = self
        config.leftIcon = icon
        return config
    }

    /// 오른쪽 아이콘을 변경한 새로운 설정 반환
    public func withRightIcon(_ icon: UIImage?) -> Self {
        var config = self
        config.rightIcon = icon
        return config
    }

    /// 사용 가능 여부를 변경한 새로운 설정 반환
    public func withEnabled(_ enabled: Bool) -> Self {
        var config = self
        config.isEnabled = enabled
        return config
    }

    /// 가로 채우기 여부를 변경한 새로운 설정 반환
    public func withFullWidth(_ fullWidth: Bool) -> Self {
        var config = self
        config.isFullWidth = fullWidth
        return config
    }
}

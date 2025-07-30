// Copyright © 2025 Booket. All rights reserved

import UIKit

/// `BKButton`의 크기 타입을 정의하는 열거형입니다.
///
/// 버튼의 높이, 패딩, 폰트, 아이콘 크기, 모서리 반경 등 레이아웃 관련 속성에 영향을 줍니다.
public enum BKButtonSize {
    /// 작은 버튼
    case small
    
    /// 중간 크기 버튼
    case medium
    
    /// 대형 버튼
    case large
    
    /// 둥근 버튼
    case rounded
    
    /// 버튼 높이 값
    var height: CGFloat {
        switch self {
        case .small, .rounded:
            38
        case .medium:
            46
        case .large:
            52
        }
    }
    
    /// 버튼 좌우 패딩 값
    var horizontalPadding: CGFloat {
        switch self {
        case .small, .rounded:
            BKSpacing.spacing3
        case .medium:
            BKSpacing.spacing4
        case .large:
            BKSpacing.spacing5
        }
    }
    
    /// 버튼 상하 패딩 값
    var verticalPadding: CGFloat {
        switch self {
        case .small, .rounded:
            BKSpacing.spacing2
        case .medium, .large:
            BKSpacing.spacing3
        }
    }
    
    /// 버튼 텍스트에 사용할 폰트
    var font: UIFont {
        switch self {
        case .rounded, .small, .medium:
            BKTextStyle
                .label1(weight: .medium).uiFont ??
                .systemFont(
                    ofSize: BKTextStyle.label1(weight: .medium).fontAttributes.fontSize.rawValue,
                    weight: .medium
                )
        case .large:
            BKTextStyle
                .body1(weight: .medium).uiFont ??
                .systemFont(
                    ofSize: BKTextStyle.body1(weight: .medium).fontAttributes.fontSize.rawValue,
                    weight: .medium
                )
        }
    }
    
    /// 아이콘의 크기
    var iconSize: CGSize {
        switch self {
        case .large:
            CGSize(width: 24, height: 24)
        default:
            CGSize(width: 22, height: 22)
        }
    }
    
    /// 아이콘과 텍스트 사이의 간격
    var iconSpacing: CGFloat {
        switch self {
        case .rounded, .small, .medium:
            BKSpacing.spacing1
        case .large:
            BKSpacing.spacing2
        }
    }
    
    /// 기본 모서리 반경
    var cornerRadius: CGFloat {
        switch self {
        case .small:
            BKRadius.xsmall
        case .medium, .large:
            BKRadius.small
        case .rounded:
            BKRadius.full
        }
    }
    
    /// 버튼의 넓이를 기준으로 계산된 둥근 corner radius 반환
    ///
    /// - Parameter width: 버튼의 실제 넓이
    /// - Returns: radius 값
    public func cornerRadius(for width: CGFloat) -> CGFloat {
        switch self {
        case .small:
            return BKRadius.xsmall
        case .medium, .large:
            return BKRadius.small
        case .rounded:
            return width / 2
        }
    }
}

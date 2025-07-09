// Copyright © 2025 Booket. All rights reserved

import UIKit

/// 버튼의 시각적 스타일을 정의하는 열거형입니다.
///
/// 각 스타일은 고유한 배경색 및 텍스트 색상을 가지며,
/// 버튼의 목적과 사용 맥락에 따라 적절한 시각적 표현을 제공합니다.
public enum BKButtonStyle {
    /// 강한 강조의 기본 버튼 스타일
    case primary
    
    /// 중간 강조의 보조 버튼 스타일
    case secondary
    
    /// 가장 낮은 강조의 텍스트 중심 스타일
    case tertiary
    
    /// 직접 색상을 정의하는 커스텀 스타일
    case custom(background: BKButtonColorSet, foreground: BKButtonColorSet)
    
    /// 스타일에 따른 배경색 세트입니다.
    ///
    /// 버튼 상태별 색상(normal, pressed, disabled)을 포함합니다.
    var backgroundColors: BKButtonColorSet {
        switch self {
        case .primary:
            return BKButtonColorSet(
                normal: .bkBackgroundColor(.primary),
                pressed: .bkBackgroundColor(.primaryPressed),
                disabled: .bkBackgroundColor(.disable)
            )
            
        case .secondary:
            return BKButtonColorSet(
                normal: .bkBackgroundColor(.secondary),
                pressed: .bkBackgroundColor(.secondaryPressed),
                disabled: .bkBackgroundColor(.disable)
            )
            
        case .tertiary:
            return BKButtonColorSet(
                normal: .bkBackgroundColor(.tertiary),
                pressed: .bkBackgroundColor(.tertiaryPressed),
                disabled: .bkBackgroundColor(.disable)
            )
            
        case .custom(let background, _):
            return background
        }
    }
    
    /// 스타일에 따른 텍스트 색상 세트입니다.
    ///
    /// 버튼 상태별 색상(normal, pressed, disabled)을 포함합니다.
    var foregroundColors: BKButtonColorSet {
        switch self {
        case .primary:
            return BKButtonColorSet(
                normal: .bkContentColor(.inverse),
                pressed: .bkContentColor(.inverse),
                disabled: .bkContentColor(.disable)
            )
            
        case .secondary:
            return BKButtonColorSet(
                normal: .bkContentColor(.primary),
                pressed: .bkContentColor(.primary),
                disabled: .bkContentColor(.disable)
            )
            
        case .tertiary:
            return BKButtonColorSet(
                normal: .bkContentColor(.brand),
                pressed: .bkContentColor(.brand),
                disabled: .bkContentColor(.disable)
            )
            
        case .custom(_, let foreground):
            return foreground
        }
    }
}

/// 버튼의 상태별 색상 세트를 정의하는 구조체입니다.
public struct BKButtonColorSet {
    /// 기본(normal) 상태에서의 색상
    let normal: UIColor
    
    /// 눌림(pressed) 상태에서의 색상
    let pressed: UIColor
    
    /// 비활성화(disabled) 상태에서의 색상
    let disabled: UIColor
    
    /// 버튼의 상태에 맞는 색상을 반환합니다.
    ///
    /// - Parameter state: 버튼의 현재 상태
    /// - Returns: 해당 상태에 맞는 색상
    public func color(for state: BKButtonState) -> UIColor {
        switch state {
        case .normal: return normal
        case .pressed: return pressed
        case .disabled: return disabled
        }
    }
    
    /// 단일 색상을 모든 상태에 적용하는 간단 생성자
    public static func solid(_ color: UIColor) -> BKButtonColorSet {
        BKButtonColorSet(normal: color, pressed: color, disabled: color)
    }
}

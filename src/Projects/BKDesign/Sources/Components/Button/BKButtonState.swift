// Copyright © 2025 Booket. All rights reserved

import UIKit

/// `BKButton`의 시각적 상태를 나타내는 열거형입니다.
///
/// 버튼의 활성화 여부 및 강조 상태에 따라 결정되며, 스타일 렌더링에 사용됩니다.
public enum BKButtonState {
    /// 기본(normal) 상태
    case normal

    /// 터치 강조(pressed) 상태
    case pressed

    /// 비활성화(disabled) 상태
    case disabled

    /// 버튼의 `isEnabled`와 `isHighlighted` 속성을 바탕으로
    /// 적절한 상태를 초기화합니다.
    ///
    /// - Parameters:
    ///   - isEnabled: 버튼이 활성화되어 있는지 여부
    ///   - isHighlighted: 버튼이 강조 상태인지 여부
    public init(isEnabled: Bool, isHighlighted: Bool) {
        if !isEnabled {
            self = .disabled
        } else if isHighlighted {
            self = .pressed
        } else {
            self = .normal
        }
    }
}

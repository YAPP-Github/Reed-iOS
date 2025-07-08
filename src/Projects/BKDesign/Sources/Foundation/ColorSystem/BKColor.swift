// Copyright © 2025 Booket. All rights reserved

import UIKit

// MARK: - BKColorMode: 라이트/다크 모드를 나타내는 Enum
// 추후 다크 모드 추가 시 .dark 케이스를 확장합니다.
public enum BKColorMode {
    case light
    // case dark
}

// MARK: - Global BKColor Enum: 최종적으로 앱에서 사용할 컬러 정의
public enum BKColor {
    // Atomic Colors
    public static var neutral: BKAtomicColor.Neutral.Type { BKAtomicColor.Neutral.self }
    public static var common: BKAtomicColor.Common.Type { BKAtomicColor.Common.self }
    public static var green: BKAtomicColor.Green.Type { BKAtomicColor.Green.self }
    public static var red: BKAtomicColor.Red.Type { BKAtomicColor.Red.self }
    public static var yellow: BKAtomicColor.Yellow.Type { BKAtomicColor.Yellow.self }
    public static var blue: BKAtomicColor.Blue.Type { BKAtomicColor.Blue.self }

    // Semantic Colors
    public static var background: BKSemanticColor.Background.Type { BKSemanticColor.Background.self }
    public static var content: BKSemanticColor.Content.Type { BKSemanticColor.Content.self }
    public static var border: BKSemanticColor.Border.Type { BKSemanticColor.Border.self }
    public static var divider: BKSemanticColor.Divider.Type { BKSemanticColor.Divider.self }
    public static var base: BKSemanticColor.Base.Type { BKSemanticColor.Base.self }
}

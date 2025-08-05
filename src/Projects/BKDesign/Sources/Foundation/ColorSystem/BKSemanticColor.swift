// Copyright © 2025 Booket. All rights reserved

import UIKit

// MARK: - Semantic Colors: UI 요소에 의미를 부여하는 색상 정의
public enum BKSemanticColor {
    // Background Colors
    public enum Background {
        case primary
        case secondary
        case tertiary
        case primaryPressed
        case secondaryPressed
        case tertiaryPressed
        case home
        case disable
        
        public func resolve(for mode: BKColorMode) -> UIColor {
            switch mode {
            case .light: // "Atomic/Mode 1" 기준
                switch self {
                case .primary: return BKAtomicColor.Green.g500.color
                case .secondary: return BKAtomicColor.Neutral.n100.color
                case .tertiary: return BKAtomicColor.Green.g100.color
                case .primaryPressed: return BKAtomicColor.Green.g600.color
                case .secondaryPressed: return BKAtomicColor.Neutral.n200.color
                case .tertiaryPressed: return BKAtomicColor.Green.g200.color
                case .home: return UIColor(hex: "#F2F8E9")
                case .disable: return BKAtomicColor.Neutral.n200.color
                }
            // case .dark: // 추후 다크 모드 색상을 여기에 정의합니다.
                // switch self { /* dark mode colors */ }
            }
        }
    }
    
    // Content Colors (텍스트, 아이콘 등)
    public enum Content {
        case primary
        case secondary
        case tertiary
        case brand
        case disable
        case info
        case success
        case warning
        case error
        case inverse
        
        public func resolve(for mode: BKColorMode) -> UIColor {
            switch mode {
            case .light:
                switch self {
                case .primary: return BKAtomicColor.Neutral.n800.color
                case .secondary: return BKAtomicColor.Neutral.n500.color
                case .tertiary: return BKAtomicColor.Neutral.n400.color
                case .brand: return BKAtomicColor.Green.g500.color
                case .disable: return BKAtomicColor.Neutral.n400.color
                case .info: return BKAtomicColor.Blue.b500.color
                case .success: return BKAtomicColor.Green.g400.color
                case .warning: return BKAtomicColor.Yellow.y300.color
                case .error: return BKAtomicColor.Red.r500.color
                case .inverse: return BKAtomicColor.Common.white.color
                }
            // case .dark:
                // switch self { /* dark mode colors */ }
            }
        }
    }
    
    // Border Colors
    public enum Border {
        case primary
        case brand
        case error
        
        public func resolve(for mode: BKColorMode) -> UIColor {
            switch mode {
            case .light:
                switch self {
                case .primary: return BKAtomicColor.Neutral.n200.color
                case .brand: return BKAtomicColor.Green.g500.color
                case .error: return BKAtomicColor.Red.r500.color
                }
            // case .dark:
                // switch self { /* dark mode colors */ }
            }
        }
    }
    
    // Divider Colors
    public enum Divider {
        case small
        case medium
        
        public func resolve(for mode: BKColorMode) -> UIColor {
            switch mode {
            case .light:
                switch self {
                case .small: return BKAtomicColor.Neutral.n200.color
                case .medium: return BKAtomicColor.Neutral.n100.color
                }
            // case .dark:
                // switch self { /* dark mode colors */ }
            }
        }
    }
    
    // Base Colors
    public enum Base {
        case primary
        case secondary
        
        public func resolve(for mode: BKColorMode) -> UIColor {
            switch mode {
            case .light:
                switch self {
                case .primary: return BKAtomicColor.Common.white.color
                case .secondary: return BKAtomicColor.Neutral.n50.color
                }
            // case .dark:
                // switch self { /* dark mode colors */ }
            }
        }
    }
    
    public enum Emotion {
        case warmth
        case joy
        case tension
        case sadness

        public func resolve(for mode: BKColorMode) -> UIColor {
            switch mode {
            case .light:
                switch self {
                case .warmth: return UIColor(hex: "#E3931B")
                case .joy: return UIColor(hex: "#EE6B33")
                case .tension: return UIColor(hex: "#9A55E4")
                case .sadness: return UIColor(hex: "#2872E9")
                }
            // case .dark:
                // switch self { /* dark mode colors */ }
            }
        }
    }

    public enum EmotionBase {
        case warmth
        case joy
        case tension
        case sadness

        public func resolve(for mode: BKColorMode) -> UIColor {
            switch mode {
            case .light:
                switch self {
                case .warmth: return UIColor(hex: "#FFF5D3")
                case .joy: return UIColor(hex: "#FFEBE3")
                case .tension: return UIColor(hex: "#F3E8FF")
                case .sadness: return UIColor(hex: "#E1ECFF")
                }
            // case .dark:
                // switch self { /* dark mode colors */ }
            }
        }
    }
    
    public enum Shadow {
        case primary
        
        public func resolve(for mode: BKColorMode) -> UIColor {
            switch mode {
            case .light:
                switch self {
                case .primary: return UIColor(hex: "#BCC4BE")
                }
            }
        }
    }
}

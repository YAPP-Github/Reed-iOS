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
}

// Copyright © 2025 Booket. All rights reserved

import UIKit

public extension UIColor {
    /// HEX 문자열을 사용하여 UIColor를 초기화합니다.
    /// - Parameter hex: #RRGGBB 또는 #RRGGBBAA 형식의 HEX 문자열 (예: "#FFFFFF", "#FF000080")
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        if length == 6 {
            red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(rgb & 0x000000FF) / 255.0
        }
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // MARK: - UIKit Extension for Dynamic Colors
    // 이 확장을 통해 `BKSemanticColor`를 `UIColor`로 변환합니다.
    
    static func bkBackgroundColor(
        _ semanticColor: BKSemanticColor.Background
    ) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                // return semanticColor.resolve(for: .dark)
                return semanticColor.resolve(for: .light)
            default:
                return semanticColor.resolve(for: .light)
            }
        }
    }
    
    static func bkContentColor(
        _ semanticColor: BKSemanticColor.Content
    ) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return semanticColor.resolve(for: .light)
            default:
                return semanticColor.resolve(for: .light)
            }
        }
    }
    
    static func bkBorderColor(
        _ semanticColor: BKSemanticColor.Border
    ) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return semanticColor.resolve(for: .light)
            default:
                return semanticColor.resolve(for: .light)
            }
        }
    }
    
    static func bkDividerColor(
        _ semanticColor: BKSemanticColor.Divider
    ) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return semanticColor.resolve(for: .light)
            default:
                return semanticColor.resolve(for: .light)
            }
        }
    }
    
    static func bkBaseColor(
        _ semanticColor: BKSemanticColor.Base
    ) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return semanticColor.resolve(for: .light)
            default:
                return semanticColor.resolve(for: .light)
            }
        }
    }
    
    static func bkEmotionColor(
        _ semanticColor: BKSemanticColor.Emotion
    ) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return semanticColor.resolve(for: .light)
            default:
                return semanticColor.resolve(for: .light)
            }
        }
    }
    
    static func bkEmotionBaseColor(
        _ semanticColor: BKSemanticColor.EmotionBase
    ) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return semanticColor.resolve(for: .light)
            default:
                return semanticColor.resolve(for: .light)
            }
        }
    }
}

// UIColor 비교를 위한 확장
extension UIColor {
    func isEqual(to color: UIColor) -> Bool {
        return self.cgColor.__equalTo(color.cgColor)
    }
}

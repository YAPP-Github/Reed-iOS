// Copyright © 2025 Booket. All rights reserved

import UIKit

public extension UIColor {
    /// HEX 문자열을 사용하여 UIColor를 초기화합니다.
    /// - Parameter hex: #RRGGBB 또는 #RRGGBBAA 형식의 HEX 문자열 (예: "#FFFFFF", "#FF000080")
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    // MARK: - UIKit Extension for Dynamic Colors
    // 이 확장을 통해 `BKSemanticColor`를 `UIColor`로 변환합니다.
    
    static func bkColor(_ semanticColor: BKSemanticColor.Background) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                // return semanticColor.resolve(for: .dark)
                return semanticColor.resolve(for: .light) // 현재는 라이트 모드 색상으로 폴백
            default: // .light, .unspecified
                return semanticColor.resolve(for: .light)
            }
        }
    }
    
    static func bkColor(_ semanticColor: BKSemanticColor.Content) -> UIColor {
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
    
    static func bkColor(_ semanticColor: BKSemanticColor.Border) -> UIColor {
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
    
    static func bkColor(_ semanticColor: BKSemanticColor.Divider) -> UIColor {
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
    
    static func bkColor(_ semanticColor: BKSemanticColor.Base) -> UIColor {
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
    
}

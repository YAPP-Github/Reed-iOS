// Copyright © 2025 Booket. All rights reserved

import UIKit

public struct BottomSheetShadow {
    public static let color: UIColor = UIColor.black.withAlphaComponent(0.1)
    public static let offset = CGSize(width: 2, height: -4)
    public static let blur: CGFloat = 20
    public static let spread: CGFloat = 0

    public static func asCALayerShadow() -> (color: CGColor, offset: CGSize, radius: CGFloat, opacity: Float) {
        return (
            color: color.cgColor,
            offset: offset,
            radius: blur,
            opacity: Float(color.cgColor.alpha)
        )
    }
}

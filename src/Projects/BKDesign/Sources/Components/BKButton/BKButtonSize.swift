// Copyright © 2025 Booket. All rights reserved

import UIKit

enum BKButtonSize {
    case small
    case medium
    case large
    case rounded
    
    var height: CGFloat {
        switch self {
        case .small, .rounded:
            40
        case .medium:
            48
        case .large:
            52
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small, .rounded:
            BKSpacing.spacing2
        case .medium:
            BKSpacing.spacing3
        case .large:
            BKSpacing.spacing3
        }
    }
    
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
    
    var iconSize: CGSize {
        CGSize(width: 24, height: 24)
    }
    
    var iconSpacing: CGFloat {
        switch self {
        case .rounded, .small, .medium:
            BKSpacing.spacing1
        case .large:
            BKSpacing.spacing2
        }
    }
    
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
}

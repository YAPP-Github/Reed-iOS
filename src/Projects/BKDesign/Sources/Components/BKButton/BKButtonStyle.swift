// Copyright © 2025 Booket. All rights reserved

import UIKit

enum BKButtonStyle {
    case primary
    case secondary
    case tertiary
    
    var backgroundColor: BKButtonColorSet {
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
        }
    }
    
    var foregroundColor: BKButtonColorSet {
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
        }
    }
    
}

struct BKButtonColorSet {
    let normal: UIColor
    let pressed: UIColor
    let disabled: UIColor
    
    init(normal: UIColor, pressed: UIColor, disabled: UIColor) {
        self.normal = normal
        self.pressed = pressed
        self.disabled = disabled
    }
    
    public func color(for state: BKButtonState) -> UIColor {
        switch state {
        case .normal: return normal
        case .pressed: return pressed
        case .disabled: return disabled
        }
    }
}

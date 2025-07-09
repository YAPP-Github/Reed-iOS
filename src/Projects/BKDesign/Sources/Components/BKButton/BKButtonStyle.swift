// Copyright © 2025 Booket. All rights reserved

import UIKit

enum BKButtonStyle {
    case primary
    case secondary
    case tertiary
    
    var backgroundColor: ButtonState {
        switch self {
        case .primary:
            return ButtonState(
                normal: .bkBackgroundColor(.primary),
                pressed: .bkBackgroundColor(.primaryPressed),
                disabled: .bkBackgroundColor(.disable)
            )
            
        case .secondary:
            return ButtonState(
                normal: .bkBackgroundColor(.secondary),
                pressed: .bkBackgroundColor(.secondaryPressed),
                disabled: .bkBackgroundColor(.disable)
            )
        
        case .tertiary:
            return ButtonState(
                normal: .bkBackgroundColor(.tertiary),
                pressed: .bkBackgroundColor(.tertiaryPressed),
                disabled: .bkBackgroundColor(.disable)
            )
        }
    }
    
    var foregroundColor: ButtonState {
        switch self {
        case .primary:
            return ButtonState(
                normal: .bkContentColor(.inverse),
                pressed: .bkContentColor(.inverse),
                disabled: .bkContentColor(.disable)
            )
            
        case .secondary:
            return ButtonState(
                normal: .bkContentColor(.primary),
                pressed: .bkContentColor(.primary),
                disabled: .bkContentColor(.disable)
            )
        
        case .tertiary:
            return ButtonState(
                normal: .bkContentColor(.brand),
                pressed: .bkContentColor(.brand),
                disabled: .bkContentColor(.disable)
            )
        }
    }
    
}

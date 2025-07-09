// Copyright © 2025 Booket. All rights reserved

import UIKit

enum BKButtonState {
    case normal
    case pressed
    case disabled
    
    init(isEnabled: Bool, isHighlighted: Bool) {
        if !isEnabled {
            self = .disabled
        } else if isHighlighted {
            self = .pressed
        } else {
            self = .normal
        }
    }
}

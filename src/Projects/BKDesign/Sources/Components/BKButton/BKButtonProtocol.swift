// Copyright © 2025 Booket. All rights reserved

import UIKit

protocol BKButtonProtocol: AnyObject {
    var isDisabled: Bool { get set }
    var style: BKButtonStyle { get set }
    var size: BKButtonSize { get set }
    var title: String? { get set }
    var leftIcon: UIImage? { get set }
    var rightIcon: UIImage? { get set }
}

struct ButtonState {
    let normal: UIColor
    let pressed: UIColor
    let disabled: UIColor
    
    init(normal: UIColor, pressed: UIColor, disabled: UIColor) {
        self.normal = normal
        self.pressed = pressed
        self.disabled = disabled
    }
}

// Copyright © 2025 Booket. All rights reserved

import UIKit

public extension UILabel {
    func setBKTextStyle(_ style: BKTextStyle, text: String? = nil, color: UIColor? = nil) {
        let actualColor = color ?? self.textColor ?? .label
        if let text = text {
            self.attributedText = style.attributedString(from: text, color: actualColor)
        } else if let currentText = self.text {
            self.attributedText = style.attributedString(from: currentText, color: actualColor)
        }
    }
}

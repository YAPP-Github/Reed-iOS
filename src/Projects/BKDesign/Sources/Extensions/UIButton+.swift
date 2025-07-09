// Copyright © 2025 Booket. All rights reserved

import UIKit

public extension UIButton {
    func setBKTextStyle(
        _ style: BKTextStyle,
        title: String? = nil,
        color: UIColor? = nil,
        for state: UIControl.State = .normal) {
        let actualColor = color ?? self.titleColor(for: state) ?? .label
        
        if let title = title {
            self.setAttributedTitle(style.attributedString(from: title, color: actualColor), for: state)
        } else if let currentTitle = self.title(for: state) {
            self.setAttributedTitle(style.attributedString(from: currentTitle, color: actualColor), for: state)
        }
    }
}

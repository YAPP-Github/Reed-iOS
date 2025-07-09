// Copyright © 2025 Booket. All rights reserved

import UIKit

struct BKButtonConfiguration {
    var style: BKButtonStyle
    var size: BKButtonSize
    var title: String?
    var leftIcon: UIImage?
    var rightIcon: UIImage?
    var isEnabled: Bool = true
    var isFullWidth: Bool = false
    
    func withStyle(_ style: BKButtonStyle) -> BKButtonConfiguration {
        var config = self
        config.style = style
        return config
    }
    
    func withSize(_ size: BKButtonSize) -> BKButtonConfiguration {
        var config = self
        config.size = size
        return config
    }
    
    func withTitle(_ title: String?) -> BKButtonConfiguration {
        var config = self
        config.title = title
        return config
    }
    
    func withLeftIcon(_ icon: UIImage?) -> BKButtonConfiguration {
        var config = self
        config.leftIcon = icon
        return config
    }
    
    func withRightIcon(_ icon: UIImage?) -> BKButtonConfiguration {
        var config = self
        config.rightIcon = icon
        return config
    }
    
    func withEnabled(_ enabled: Bool) -> BKButtonConfiguration {
        var config = self
        config.isEnabled = enabled
        return config
    }
    
    func withFullWidth(_ fullWidth: Bool) -> BKButtonConfiguration {
        var config = self
        config.isFullWidth = fullWidth
        return config
    }
}

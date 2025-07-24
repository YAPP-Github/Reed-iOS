// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit

enum TabItem: CaseIterable {
    case home
    case archive

    var title: String {
        switch self {
        case .home: return "홈"
        case .archive: return "내 서재"
        }
    }

    var icon: UIImage {
        switch self {
        case .home: return BKImage.Icon.home
        case .archive: return BKImage.Icon.archive
        }
    }
}

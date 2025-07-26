// Copyright © 2025 Booket. All rights reserved

import UIKit

struct ChipData: Hashable, Equatable {
    let title: String
    let count: Int
    var isSelected: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: ChipData, rhs: ChipData) -> Bool {
        lhs.title == rhs.title
    }
}

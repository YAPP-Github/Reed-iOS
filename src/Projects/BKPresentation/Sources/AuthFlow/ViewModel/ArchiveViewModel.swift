// Copyright © 2025 Booket. All rights reserved

import UIKit

struct ArchiveBook: Hashable {
    let title: String
    let author: String
    let publisher: String
    let imageURL: URL?
    let recordCount: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(author)
    }
}

struct ChipData: Hashable {
    let title: String
    let count: Int
    var isSelected: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

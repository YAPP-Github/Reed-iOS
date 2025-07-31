// Copyright © 2025 Booket. All rights reserved

import UIKit

struct ChipData: Hashable, Equatable {
    let title: String
    let count: Int
    var isSelected: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (
        lhs: ChipData,
        rhs: ChipData
    ) -> Bool {
        lhs.title == rhs.title
    }
}

enum ChipType: Int, CaseIterable {
    case total = 0
    case toRead = 1
    case reading = 2
    case completed = 3
    
    var title: String {
        switch self {
        case .total: return "전체"
        case .toRead: return "읽기 전"
        case .reading: return "읽는 중"
        case .completed: return "완독"
        }
    }
    
    var bookStatus: BookStatus? {
        switch self {
        case .total: return .total
        case .toRead: return .toRead
        case .reading: return .reading
        case .completed: return .completed
        }
    }
}

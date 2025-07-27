// Copyright © 2025 Booket. All rights reserved

import UIKit

struct Term: Hashable, Identifiable {
    let id = UUID()
    var title: String
    var url: URL?
    var isRequired: Bool
    var isAgreed: Bool = false
}

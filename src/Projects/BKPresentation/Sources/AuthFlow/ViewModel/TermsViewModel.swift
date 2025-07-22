// Copyright © 2025 Booket. All rights reserved

import UIKit

struct TermsViewObject: Equatable {
    let title: String
    let url: URL?
    
    init(
        title: String,
        url: URL? = nil
    ) {
        self.title = title
        self.url = url
    }
}

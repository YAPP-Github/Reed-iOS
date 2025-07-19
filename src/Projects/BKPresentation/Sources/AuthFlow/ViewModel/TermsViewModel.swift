// Copyright © 2025 Booket. All rights reserved

import UIKit

struct TermsViewObject {
    let title: String
    let URL: URL?
    
    init(title: String, URL: URL? = nil) {
        self.title = title
        self.URL = URL
    }
}

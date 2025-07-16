// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine
import UIKit

final class TermsViewController: BaseViewController<TermsView> {
    
    override var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        .standard(
            viewController: self,
            rightButton: .none
        )
    }
    
    override var bkNavigationTitle: String {
        return ""
    }
    
}

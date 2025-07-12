// Copyright © 2025 Booket. All rights reserved

import UIKit

final class BottomSheetTitleViewController: BaseViewController<BKBottomSheetTitleTestView> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "BottomSheet title"
    }
}

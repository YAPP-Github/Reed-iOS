// Copyright © 2025 Booket. All rights reserved

import UIKit

final class BKInputCatalogViewController: BaseViewController<BKInputCatalogView> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Label, TextField"
    }
}

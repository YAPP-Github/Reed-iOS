// Copyright © 2025 Booket. All rights reserved

import BKCore
import UIKit

struct AppStoreLinker {
    private static let appID = "6747740414"
    
    static func openAppStore() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)") else {
            Log.debug("Invalid App Store URL", logger: AppLogger.network)
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            Log.debug("Can't open App Store URL", logger: AppLogger.network)
        }
    }
}

// Copyright © 2025 Booket. All rights reserved

import UIKit

struct AppStoreLinker {
    private static let appID = "6747740414"
    
    static func openAppStore() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)") else {
            print("Invalid App Store URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Can't open App Store URL")
        }
    }
}

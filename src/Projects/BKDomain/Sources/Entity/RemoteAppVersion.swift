// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct RemoteAppVersion {
    public let latestVersion: String
    public let minimumRequiredVersion: String
    
    public init(latestVersion: String, minimumRequiredVersion: String) {
        self.latestVersion = latestVersion
        self.minimumRequiredVersion = minimumRequiredVersion
    }
}

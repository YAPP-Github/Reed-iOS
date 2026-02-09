// Copyright © 2025 Booket. All rights reserved

import Foundation

private final class BKDataBundleToken {}

enum APIConfig {
    private static let bundle = Bundle(for: BKDataBundleToken.self)
    
    static let baseURL: String = {
        guard let value = bundle.object(forInfoDictionaryKey: "BASE_API_URL") as? String else {
            fatalError("Can't load environment: BKData.BASE_API_URL")
        }
        return value
    }()
    
    static let baseV2URL: String = {
        guard let value = bundle.object(forInfoDictionaryKey: "BASE_API_V2_URL") as? String else {
            fatalError("Can't load environment: BKData.BASE_API_V2_URL")
        }
        return value
    }()
}

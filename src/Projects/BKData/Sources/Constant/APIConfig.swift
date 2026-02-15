// Copyright © 2025 Booket. All rights reserved

import Foundation

private final class BKDataBundleToken {}

enum APIConfig {
    private static let bundle = Bundle(for: BKDataBundleToken.self)

    /// API Base URL (xcconfig에서 /api까지만 포함)
    private static let baseURL: String = {
        guard let value = bundle.object(forInfoDictionaryKey: "BASE_API_URL") as? String else {
            fatalError("Can't load environment: BKData.BASE_API_URL")
        }
        return value
    }()

    /// V1 API Base URL (auth, books, users, home)
    static let baseURLv1: String = {
        return baseURL + "/v1"
    }()

    /// V2 API Base URL (emotions, reading-records)
    static let baseURLv2: String = {
        return baseURL + "/v2"
    }()
}

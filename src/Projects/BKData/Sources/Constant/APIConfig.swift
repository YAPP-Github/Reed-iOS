// Copyright © 2025 Booket. All rights reserved

import Foundation

private final class BKDataBundleToken {}

enum APIConfig {
    private static let bundle = Bundle(for: BKDataBundleToken.self)

    /// V1 API Base URL (auth, books, users, home)
    static let baseURL: String = {
        guard let value = bundle.object(forInfoDictionaryKey: "BASE_API_URL") as? String else {
            fatalError("Can't load environment: BKData.BASE_API_URL")
        }
        return value
    }()

    /// V2 API Base URL (emotions, reading-records)
    static let baseURLv2: String = {
        // V1 URL에서 v2로 변경
        return baseURL.replacingOccurrences(of: "/api/v1", with: "/api/v2")
    }()
}

// Copyright © 2025 Booket. All rights reserved

public protocol TokenProvider {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    func clearCache()
}

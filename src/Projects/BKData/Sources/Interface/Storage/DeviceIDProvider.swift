// Copyright © 2025 Booket. All rights reserved

public protocol DeviceIDProvider {
    var deviceID: String? { get }
    func clearCache()
}

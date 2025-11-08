// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import OSLog

public final class KeychainDeviceIDProvider: DeviceIDProvider {
    private let storage: KeyValueStorage
    private var cachedDeviceID: String?

    public init(storage: KeyValueStorage) {
        self.storage = storage
    }
    
    public var deviceID: String? {
        if let cachedDeviceID {
            return cachedDeviceID
        }
        do {
            let id: String = try storage.load(for: StorageKeys.deviceIDKey)
            self.cachedDeviceID = id
            return id
        } catch {
            Log.error("Failed to load deviceID: \(error)", logger: AppLogger.storage)
            return nil
        }
    }
    
    public func clearCache() {
        cachedDeviceID = nil
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKDomain

public struct DefaultOnboardingRepository: OnboardingRepository {
    private let storage: KeyValueStorage
    private let key = "onboardingHasCompleted"
    
    public init(storage: KeyValueStorage) {
        self.storage = storage
    }
    
    public func fetchOnboardingSeen() -> Bool {
        do {
            return try storage.load(for: key)
        } catch {
            return false
        }
    }
    
    public func saveOnboardingSeen() {
        try? storage.save(true, for: key)
    }
    
    public func resetOnboardingSeen() {
        try? storage.save(false, for: key)
    }
}

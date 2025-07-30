// Copyright © 2025 Booket. All rights reserved

public protocol OnboardingRepository {
    func fetchOnboardingSeen() -> Bool
    func saveOnboardingSeen()
}

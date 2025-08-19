import Combine

public final class AccessModeCenter {
    public static let shared = AccessModeCenter()
    private init() {}

    public let mode = CurrentValueSubject<AppAccessMode, Never>(.guest)
}

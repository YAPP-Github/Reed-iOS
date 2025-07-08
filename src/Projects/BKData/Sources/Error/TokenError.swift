// Copyright © 2025 Booket. All rights reserved

public enum TokenError: Error {
    case saveFailed(underlying: Error)
    case clearFailed(underlying: Error)
}

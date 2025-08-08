// Copyright © 2025 Booket. All rights reserved

import Foundation

public enum DomainError: Error {
    case unauthorized
    case clientError
    case internalServerError
    case timeout
}

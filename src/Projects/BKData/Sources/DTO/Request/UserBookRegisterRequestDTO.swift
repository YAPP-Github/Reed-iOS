// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

struct UserBookRegisterRequestDTO: Encodable {
    let bookIsbn: String
    let bookStatus: BookStatus
}

// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct Book: Hashable {
    public let isbn: String
    public let title: String
    public let author: String
    public let publisher: String
    public let thumbnail: URL?
    public let userBookStatus: String
}

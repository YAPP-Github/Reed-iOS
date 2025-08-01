// Copyright © 2025 Booket. All rights reserved

import Foundation

public enum LibrarySortType: String, Encodable, CustomStringConvertible {
    case titleAsc = "TITLE_ASC"
    case titleDesc = "TITLE_DESC"
    case dateAsc = "CREATED_DATE_ASC"
    case dateDesc = "CREATED_DATE_DESC"
    
    public var description: String { rawValue }
}

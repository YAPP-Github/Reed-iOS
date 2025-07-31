// Copyright © 2025 Booket. All rights reserved

import Foundation

public enum LibrarySortType: String, Encodable, CustomStringConvertible {
    case title_asc = "TITLE_ASC"
    case title_desc = "TITLE_DESC"
    case date_asc = "CREATED_DATE_ASC"
    case date_desc = "CREATED_DATE_DESC"
    
    public var description: String { rawValue }
}

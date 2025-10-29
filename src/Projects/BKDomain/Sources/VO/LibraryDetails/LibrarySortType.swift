// Copyright © 2025 Booket. All rights reserved

import Foundation

public enum LibrarySortType: String, Encodable, CustomStringConvertible {
    case pageNumberAsc = "PAGE_NUMBER_ASC"
    case pageNumberDesc = "PAGE_NUMBER_DESC"
    case createdDateAsc = "CREATED_DATE_ASC"
    case createdDateDesc = "CREATED_DATE_DESC"
    case updatedDateAsc = "UPDATED_DATE_ASC"
    case updatedDateDesc = "UPDATED_DATE_DESC"
    
    public var description: String { rawValue }
}

// Copyright © 2025 Booket. All rights reserved

import Foundation

public enum RecordSortType: String, Encodable, CustomStringConvertible {
    case page_number_asc = "PAGE_NUMBER_ASC"
    case page_number_desc = "PAGE_NUMBER_DESC"
    case created_date_asc = "CREATED_DATE_ASC"
    case created_date_desc = "CREATED_DATE_DESC"
    
    public var description: String { rawValue }
}

// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct RecordVO {
    public let pageNumber: Int
    public let quote: String
    public let review: String
    public let emotionTags: [String]
    
    public init(
        pageNumber: Int,
        quote: String,
        review: String,
        emotionTags: [String]
    ) {
        self.pageNumber = pageNumber
        self.quote = quote
        self.review = review
        self.emotionTags = emotionTags
    }
}

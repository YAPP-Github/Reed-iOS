// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

public struct RecordPostDTO: Encodable {
    let pageNumber: Int
    let quote: String
    let review: String
    let emotionTags: [String]
    
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
    
    public init(data: RecordVO) {
        self.init(
            pageNumber: data.pageNumber,
            quote: data.quote,
            review: data.review,
            emotionTags: data.emotionTags
        )
    }
}

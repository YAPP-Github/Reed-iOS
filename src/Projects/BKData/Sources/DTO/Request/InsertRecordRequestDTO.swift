// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

struct InsertRecordRequestDTO: Encodable {
    let pageNumber: Int?
    let quote: String
    let review: String?
    let primaryEmotion: String
    let detailEmotionTagIds: [String]

    init(
        pageNumber: Int?,
        quote: String,
        review: String?,
        primaryEmotion: String,
        detailEmotionTagIds: [String]
    ) {
        self.pageNumber = pageNumber
        self.quote = quote
        self.review = review
        self.primaryEmotion = primaryEmotion
        self.detailEmotionTagIds = detailEmotionTagIds
    }

    init(data: RecordVO) {
        self.init(
            pageNumber: data.pageNumber,
            quote: data.quote,
            review: data.memo,
            primaryEmotion: data.primaryEmotion.rawValue,
            detailEmotionTagIds: data.detailEmotionIds
        )
    }
}

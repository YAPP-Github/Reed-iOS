// Copyright © 2025 Booket. All rights reserved

import Foundation

public struct RecordVO {
    public let pageNumber: Int?
    public let quote: String
    public let memo: String?
    public let primaryEmotion: PrimaryEmotion
    public let detailEmotionIds: [String]

    public init(
        pageNumber: Int?,
        quote: String,
        memo: String?,
        primaryEmotion: PrimaryEmotion,
        detailEmotionIds: [String]
    ) {
        self.pageNumber = pageNumber
        self.quote = quote
        self.memo = memo
        self.primaryEmotion = primaryEmotion
        self.detailEmotionIds = detailEmotionIds
    }
}

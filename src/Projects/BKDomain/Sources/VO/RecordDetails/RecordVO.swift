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

    /// 이전 API와의 호환성을 위한 생성자
    public init(
        pageNumber: Int?,
        quote: String,
        review: String?,
        emotionTags: [String]
    ) {
        self.pageNumber = pageNumber
        self.quote = quote
        self.memo = review
        self.primaryEmotion = .other
        self.detailEmotionIds = emotionTags
    }
}

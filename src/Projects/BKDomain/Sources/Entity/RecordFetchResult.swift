// Copyright © 2026 Booket. All rights reserved

import Foundation

public struct RecordFetchResult {
    public let infos: [RecordInfo]
    public let hasMore: Bool
    public let totalCount: Int
    public let mainEmotion: Emotion?
    
    public init(
        infos: [RecordInfo],
        hasMore: Bool,
        totalCount: Int,
        mainEmotion: Emotion?
    ) {
        self.infos = infos
        self.hasMore = hasMore
        self.totalCount = totalCount
        self.mainEmotion = mainEmotion
    }
}

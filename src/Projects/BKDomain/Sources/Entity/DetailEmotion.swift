// Copyright © 2025 Booket. All rights reserved

import Foundation

/// 세부 감정 (서버에서 가져온 데이터)
public struct DetailEmotion: Codable, Equatable, Hashable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

/// 감정 그룹 (대분류 + 세부감정 목록)
public struct EmotionGroup: Codable, Equatable {
    public let primaryEmotion: PrimaryEmotion
    public let displayName: String
    public let detailEmotions: [DetailEmotion]

    public init(
        primaryEmotion: PrimaryEmotion,
        displayName: String,
        detailEmotions: [DetailEmotion]
    ) {
        self.primaryEmotion = primaryEmotion
        self.displayName = displayName
        self.detailEmotions = detailEmotions
    }
}

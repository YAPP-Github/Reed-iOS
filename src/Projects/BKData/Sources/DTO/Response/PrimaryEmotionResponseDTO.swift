// Copyright © 2026 Booket. All rights reserved

import BKDomain

public struct PrimaryEmotionResponseDTO: Decodable {
    let code: String
    let displayName: String

    func toDomain() -> PrimaryEmotion {
        return PrimaryEmotion(rawValue: code) ?? .other
    }
}

public struct DetailEmotionResponseDTO: Decodable {
    let id: String
    let name: String

    func toDomain() -> DetailEmotion {
        return DetailEmotion(id: id, name: name)
    }
}

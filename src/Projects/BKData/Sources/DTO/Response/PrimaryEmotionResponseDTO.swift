// Copyright © 2026 Booket. All rights reserved

import BKDomain

public struct PrimaryEmotionResponseDTO: Decodable {
    let code: String
    let displayName: Emotion
}

public struct DetailEmotionResponseDTO: Decodable {
    let id: String
    let name: String
}

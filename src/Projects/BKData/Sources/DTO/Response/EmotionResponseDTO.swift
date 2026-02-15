// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

// MARK: - API Response DTO

struct EmotionListResponseDTO: Decodable {
    let emotions: [EmotionGroupDTO]
}

struct EmotionGroupDTO: Decodable {
    let code: String
    let displayName: String
    let detailEmotions: [DetailEmotionDTO]
}

struct DetailEmotionDTO: Decodable {
    let id: String
    let name: String
}

// MARK: - Mapping to Domain

extension EmotionGroupDTO {
    func toDomain() -> EmotionGroup? {
        guard let primaryEmotion = PrimaryEmotion(rawValue: code) else {
            return nil
        }
        return EmotionGroup(
            primaryEmotion: primaryEmotion,
            displayName: displayName,
            detailEmotions: detailEmotions.map { $0.toDomain() }
        )
    }
}

extension DetailEmotionDTO {
    func toDomain() -> DetailEmotion {
        return DetailEmotion(id: id, name: name)
    }
}

// MARK: - Response에서 사용하는 DTO (기록 조회 시)

struct PrimaryEmotionDTO: Decodable {
    let code: String
    let displayName: String

    func toDomain() -> PrimaryEmotion? {
        return PrimaryEmotion(rawValue: code)
    }
}

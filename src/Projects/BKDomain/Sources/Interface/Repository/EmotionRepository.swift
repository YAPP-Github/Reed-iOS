// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol EmotionRepository {
    /// 서버에서 감정 목록 가져오기
    func fetchEmotions() -> AnyPublisher<[EmotionGroup], DomainError>

    /// 캐시된 감정 목록 가져오기 (없으면 서버에서 가져옴)
    func getEmotions() -> AnyPublisher<[EmotionGroup], DomainError>

    /// 특정 대분류 감정의 세부감정 목록 가져오기
    func getDetailEmotions(for primaryEmotion: PrimaryEmotion) -> AnyPublisher<[DetailEmotion], DomainError>

    /// 세부감정 이름으로 ID 찾기
    func findDetailEmotionId(name: String, in primaryEmotion: PrimaryEmotion) -> AnyPublisher<String?, DomainError>

    /// 세부감정 ID로 이름 찾기
    func findDetailEmotionName(id: String) -> AnyPublisher<String?, DomainError>
}

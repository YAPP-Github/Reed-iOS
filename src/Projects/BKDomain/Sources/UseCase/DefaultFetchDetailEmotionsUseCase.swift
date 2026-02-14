// Copyright © 2025 Booket. All rights reserved

import Combine

public struct DefaultFetchDetailEmotionsUseCase: FetchDetailEmotionsUseCase {
    private let repository: EmotionRepository

    public init(repository: EmotionRepository) {
        self.repository = repository
    }

    public func execute(for primaryEmotion: PrimaryEmotion) -> AnyPublisher<[DetailEmotion], DomainError> {
        repository.getDetailEmotions(for: primaryEmotion)
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDomain
import Combine
import Foundation

public final class DefaultEmotionRepository: EmotionRepository {
    private let networkProvider: NetworkProvider
    private var cachedEmotions: [EmotionGroup]?
    private let cacheQueue = DispatchQueue(label: "com.booket.emotion.cache")

    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    public func fetchEmotions() -> AnyPublisher<[EmotionGroup], DomainError> {
        networkProvider.request(
            target: EmotionAPI.fetchEmotions,
            type: EmotionListResponseDTO.self
        )
        .mapError { $0.toDomainError() }
        .debugError(logger: AppLogger.network)
        .map { [weak self] response in
            let emotions = response.emotions.compactMap { $0.toDomain() }
            self?.cacheQueue.sync {
                self?.cachedEmotions = emotions
            }
            return emotions
        }
        .eraseToAnyPublisher()
    }

    public func getEmotions() -> AnyPublisher<[EmotionGroup], DomainError> {
        var cached: [EmotionGroup]?
        cacheQueue.sync {
            cached = cachedEmotions
        }

        if let cached {
            return Just(cached)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        return fetchEmotions()
    }

    public func getDetailEmotions(for primaryEmotion: PrimaryEmotion) -> AnyPublisher<[DetailEmotion], DomainError> {
        getEmotions()
            .map { groups in
                groups.first { $0.primaryEmotion == primaryEmotion }?.detailEmotions ?? []
            }
            .eraseToAnyPublisher()
    }

    public func findDetailEmotionId(name: String, in primaryEmotion: PrimaryEmotion) -> AnyPublisher<String?, DomainError> {
        getDetailEmotions(for: primaryEmotion)
            .map { detailEmotions in
                detailEmotions.first { $0.name == name }?.id
            }
            .eraseToAnyPublisher()
    }

    public func findDetailEmotionName(id: String) -> AnyPublisher<String?, DomainError> {
        getEmotions()
            .map { groups in
                for group in groups {
                    if let emotion = group.detailEmotions.first(where: { $0.id == id }) {
                        return emotion.name
                    }
                }
                return nil
            }
            .eraseToAnyPublisher()
    }
}

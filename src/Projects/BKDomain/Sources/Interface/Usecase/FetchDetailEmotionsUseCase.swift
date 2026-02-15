// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol FetchDetailEmotionsUseCase {
    func execute(for primaryEmotion: PrimaryEmotion) -> AnyPublisher<[DetailEmotion], DomainError>
}

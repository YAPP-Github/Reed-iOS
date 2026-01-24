// Copyright © 2026 Booket. All rights reserved

import Combine
import Foundation

public struct DefaultOpenExternalLinkUseCase: OpenExternalLinkUseCase {
    private let repository: ExternalLinkRepository
    
    init(repository: ExternalLinkRepository) {
        self.repository = repository
    }
    
    public func execute(url: String) -> AnyPublisher<Bool, Never> {
        repository.open(url)
    }
}

// Copyright © 2026 Booket. All rights reserved

import Combine
import Foundation

public struct DefaultOpenExternalLinkUseCase: OpenExternalLinkUseCase {
    private let repository: ExternalLinkRepository
    
    init(repository: ExternalLinkRepository) {
        self.repository = repository
    }
    
    public func execute(urlString: String, appScheme: String?) -> AnyPublisher<Bool, Never> {
        if let appScheme = appScheme, repository.canOpen(appScheme) {
            return repository.open(appScheme)
        }
        
        return repository.open(urlString)
    }
}

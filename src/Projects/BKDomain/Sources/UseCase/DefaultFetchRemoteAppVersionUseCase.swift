// Copyright © 2025 Booket. All rights reserved

import Combine
import Foundation

public struct DefaultFetchRemoteAppVersionUseCase: FetchRemoteAppVersionUseCase {
    
    private let repository: RemoteConfigRepository
    
    public init(repository: RemoteConfigRepository) {
        self.repository = repository
    }
    
    public func execute() -> AnyPublisher<RemoteAppVersion, Error> {
        return repository.fetchRemoteAppVersions()
    }
}

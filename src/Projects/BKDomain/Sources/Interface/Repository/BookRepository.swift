// Copyright © 2025 Booket. All rights reserved

import Combine

public protocol BookRepository {
    func search(
        _ parameters: SearchBookParameters
    ) -> AnyPublisher<([Book], totalResults: Int), Never>
    
//    func detail() -> AnyPublisher<Void, Never>
//    func myLibrary() -> AnyPublisher<[Book], Never>
//    func upsert() -> AnyPublisher<Void, Never>
}

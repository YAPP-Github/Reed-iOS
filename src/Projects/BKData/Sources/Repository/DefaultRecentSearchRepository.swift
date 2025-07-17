// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Foundation

public final class DefaultRecentSearchRepository: RecentSearchRepository {
    private let storage: KeyValueStorage
    private let key = "recent_searches"
    private let maxCount = 10

    public init(storage: KeyValueStorage) {
        self.storage = storage
    }

    public func load() -> [String] {
        (try? storage.load(for: key)) ?? []
    }

    public func save(query: String) {
        var list = load().filter { $0 != query }
        list.insert(query, at: 0)
        list = Array(list.prefix(maxCount))
        try? storage.save(list, for: key)
    }

    public func clear() {
        try? storage.delete(for: key)
    }
}

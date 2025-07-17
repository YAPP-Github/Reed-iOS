// Copyright © 2025 Booket. All rights reserved

public protocol RecentSearchRepository {
    func load() -> [String]
    func save(query: String)
    func clear()
}

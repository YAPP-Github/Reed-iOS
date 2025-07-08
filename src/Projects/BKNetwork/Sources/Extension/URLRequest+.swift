// Copyright © 2025 Booket. All rights reserved

import BKData
import Foundation

extension URLRequest {
    init(_ urlString: String, query: [String: Any]) throws {
        guard var components = URLComponents(string: urlString) else { throw NetworkError.invalidURL }
        components.queryItems = query.compactMap {
            URLQueryItem(
                name: $0.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.key,
                value: "\( $0.value )".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            )
        }
        
        guard let url = components.url else { throw NetworkError.invalidURL }
        self.init(url: url)
    }
    
    mutating func setBody<T: Encodable>(_ body: T) {
        httpBody = try? JSONEncoder().encode(body)
    }
    
    mutating func makeURLHeaders(_ headers: [String: String]) {
        for header in headers {
            addValue(header.value, forHTTPHeaderField: header.key)
        }
    }
    
    mutating func addAuthorization(_ accessToken: String) {
        if !accessToken.isEmpty {
            addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
    }
}

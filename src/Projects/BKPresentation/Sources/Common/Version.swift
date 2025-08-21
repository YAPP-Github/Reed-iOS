// Copyright © 2025 Booket. All rights reserved

import Foundation

/// 버전 문자열을 파싱하고 비교하기 위한 헬퍼 구조체
struct Version: Comparable {
    let major: Int
    let minor: Int
    let patch: Int
    
    init?(_ versionString: String) {
        let components = versionString.split(separator: ".").compactMap { Int($0) }
        guard components.count == 3 else { return nil }
        self.major = components[0]
        self.minor = components[1]
        self.patch = components[2]
    }
    
    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        return lhs.patch < rhs.patch
    }
    
    /// Major 또는 Minor 버전 업데이트가 필요한지 확인
    func isMajorOrMinorUpdateRequired(from latestVersion: Version) -> Bool {
        return self.major < latestVersion.major ||
        (self.major == latestVersion.major && self.minor < latestVersion.minor)
    }
}

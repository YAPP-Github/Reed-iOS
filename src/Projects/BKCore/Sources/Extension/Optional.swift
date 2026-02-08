// Copyright © 2026 Booket. All rights reserved

import UIKit

public extension Optional where Wrapped == Int {
    /// Int? 값을 "123p" 또는 값이 없을 경우 "-p" 문자열로 반환합니다.
    var toPageString: String {
        return self.map { "\($0)p" } ?? "-p"
    }
}

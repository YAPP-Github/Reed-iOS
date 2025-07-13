// Copyright © 2025 Booket. All rights reserved

import UIKit

extension UIView {
    /// 여러 개의 서브뷰를 한 번에 추가하는 함수
    public func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

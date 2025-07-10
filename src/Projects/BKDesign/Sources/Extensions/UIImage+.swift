// Copyright © 2025 Booket. All rights reserved

import UIKit

extension UIImage {
    /// Asset 이미지를 버튼 크기에 맞게 조정
    func resize(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(
            size: targetSize,
            format: UIGraphicsImageRendererFormat.preferred()
        )
        
        return renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

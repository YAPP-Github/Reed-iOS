// Copyright © 2025 Booket. All rights reserved

import UIKit

public final class BKDimView: UIView {
    var tapHandler: (() -> Void)?
    
    init(alpha: CGFloat = 0.5) {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(alpha)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        tapHandler?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

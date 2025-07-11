// Copyright © 2025 Booket. All rights reserved

import UIKit

class BaseView: UIView {
    // MARK: - Initialize
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.setupView()
        self.setupLayout()
        self.configure()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Common Methods
    func setupView() {}
    func setupLayout() {}
    func configure() {}
}

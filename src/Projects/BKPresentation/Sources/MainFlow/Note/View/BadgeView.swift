// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class BadgeView: UIView {
    private let label = BKLabel(
        fontStyle: .caption1(weight: .medium),
        color: .bkContentColor(.brand),
        alignment: .center
    )
    
    public var title: String {
        didSet {
            label.setText(text: title)
        }
    }
    
    public init(title: String) {
        self.title = title
        super.init(frame: .zero)
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .bkBackgroundColor(.tertiary)
        self.layer.cornerRadius = BKRadius.xsmall
        label.setText(text: title)
    }
    
    private func setupLayout() {
        addSubview(label)
        
        label.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(BKSpacing.spacing2)
            $0.top.bottom.equalToSuperview().inset(BKSpacing.spacing05)
        }
    }
}

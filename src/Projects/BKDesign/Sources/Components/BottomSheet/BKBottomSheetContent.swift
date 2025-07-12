// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public enum BKBottomSheetContent {
    case titleView(title: String)
    case titleWithTextview(title: String, text: String)
    
    public var view: UIView {
        switch self {
        case let .titleView(title):
            return setTitleLabel(title)

        case let .titleWithTextview(title, text):
            let container = UIStackView()
            container.axis = .vertical
            container.spacing = BKSpacing.spacing1
            container.alignment = .fill
            
            let titleLabel = setTitleLabel(title)
            let textLabel = setTextView(text)
            
            [titleLabel, textLabel].forEach { container.addArrangedSubview($0) }
            
            return container
        }
    }
    
    private func setTitleLabel(_ title: String) -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = BKTextStyle.heading2(weight: .semiBold).uiFont ??
            .systemFont(
                ofSize: BKTextStyle.heading2(weight: .semiBold).fontAttributes.fontSize.rawValue,
                weight: .semibold
            )
        titleLabel.textColor = .bkContentColor(.primary)
        titleLabel.textAlignment = .center
        
        return titleLabel
    }
    
    private func setTextView(_ text: String) -> UILabel {
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = BKTextStyle.body1(weight: .medium).uiFont ??
            .systemFont(
                ofSize: BKTextStyle.body1(weight: .medium).fontAttributes.fontSize.rawValue,
                weight: .medium
            )
        textLabel.textColor = .bkContentColor(.secondary)
        textLabel.textAlignment = .center
        
        return textLabel
    }
    
}

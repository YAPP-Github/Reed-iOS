// Copyright © 2025 Booket. All rights reserved

import UIKit

public final class BKDivider: UIView {
    public enum DividerType {
        case medium
        case small
    }
    
    private let type: DividerType
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: type.height)
    }
    
    public init(
        type: DividerType = .medium
    ) {
        self.type = type
        super.init(frame: .zero)
        backgroundColor = type.color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BKDivider.DividerType {
    var height: CGFloat {
        switch self {
        case .medium:
            return 8
        case .small:
            return 1
        }
    }
    
    var color: UIColor {
        switch self {
        case .medium:
            return .bkDividerColor(.medium)
        case .small:
            return .bkDividerColor(.small)
        }
    }
}

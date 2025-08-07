// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class RecordCountView: UIView {
    private let image = UIImageView(image: BKImage.Graphics.homeSeed)
    private let title = BKLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        clipsToBounds = true
        layer.masksToBounds = true
        layer.cornerRadius = LayoutConstants.cornerRadius
        backgroundColor = .bkBaseColor(.secondary)
        
        addSubviews(image, title)
        
        image.backgroundColor = .bkBaseColor(.primary)
        
        image.snp.makeConstraints {
            $0.size.equalTo(LayoutConstants.iconSize)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        title.snp.makeConstraints {
            $0.leading.equalTo(image.snp.trailing)
                .offset(LayoutConstants.spacing)
            $0.verticalEdges.equalToSuperview()
                .inset(LayoutConstants.verticalInset)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        title.setContentHuggingPriority(.required, for: .horizontal)
        title.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    public func configure(count: Int) {
        title.setText(text: "\(count)개")
        title.setFontStyle(style: .label1(weight: .medium))
        title.setColor(color: .bkContentColor(.secondary))
        title.highlightedWord = "\(count)"
        title.highlightFont = BKTextStyle.label1(weight: .semiBold).uiFont
        title.highlightColor = .bkContentColor(.brand)
    }
}

private extension RecordCountView {
    enum LayoutConstants {
        static let cornerRadius: CGFloat = BKRadius.small
        static let iconSize: CGFloat = 28
        static let verticalInset: CGFloat = 8
        static let horizontalInset: CGFloat = 12
        static let spacing: CGFloat = 4
    }
}

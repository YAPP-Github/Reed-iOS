// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class RecordCountView: UIView {
    private let image = UIView()
    private let title = BKLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = BKRadius.small
        self.backgroundColor = .bkBaseColor(.secondary)
        
        addSubviews(image, title)
        
        image.backgroundColor = .bkBaseColor(.primary)
        
        image.snp.makeConstraints {
            $0.size.equalTo(28)
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(12)
        }
        
        title.snp.makeConstraints {
            $0.leading.equalTo(image.snp.trailing).offset(4)
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview().inset(12)
        }
        
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

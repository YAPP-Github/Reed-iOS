// Copyright © 2025 Booket. All rights reserved

import BKDesign
import UIKit
import SnapKit

final class TooltipView: BaseView {
    private let textLabel = BKLabel(
        text: "예시 문장을 알려드려요",
        fontStyle: .label2(weight: .regular),
        color: .bkContentColor(.inverse),
        alignment: .center
    )
    
    private let labelText: String
    
    init(text: String) {
        self.labelText = text
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupView() {
        addSubview(textLabel)
    }
    
    override func configure() {
        backgroundColor = .clear
        textLabel.numberOfLines = 1
        textLabel.setText(text: labelText)
        
        layer.shadowColor = UIColor(hex: "#28323C").cgColor
        layer.shadowOpacity = 0.18
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }
    
    override func setupLayout() {
        textLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(18)
        }
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: rect.width - 6, height: rect.height),
            cornerRadius: 4
        )

        let midY = rect.height / 2
        path.move(to: CGPoint(x: rect.width - 6, y: midY - 6))
        path.addLine(to: CGPoint(x: rect.width, y: midY))
        path.addLine(to: CGPoint(x: rect.width - 6, y: midY + 6))
        path.close()

        UIColor.black.setFill()
        path.fill()
    }
}

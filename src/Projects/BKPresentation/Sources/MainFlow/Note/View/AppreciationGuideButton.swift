// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

enum AppreciationGuide: String, CaseIterable {
    case emotionallyMoved = "에서 위로 받았다"
    case leftDeepImpression = "이 마음에 남았다"
    case curiousAboutAuthor = "에서 작가의 의도가 궁금하다"
    case curiousAboutOthers = "에 대한 다른 사람들의 생각이 궁금하다"
    case feltEmpathy = "에서 크게 공감이 된다"
    case remindedMemory = "을 보고 예전 기억이 났다"
    case stayedInSentence = "에서 문장에 머물렀다"
    
    var reaction: String {
        let space = "______"
        return "\(space)\(rawValue)"
    }
}

final class AppreciationGuideButton: UIButton {
    private let selectedBorderColor: UIColor = .bkBorderColor(.brand)
    private let deselectedBorderColor: UIColor = .bkBorderColor(.primary)
    private let selectedBackgroundColor: UIColor = .bkBackgroundColor(.tertiary)
    private let deselectedBackgroundColor: UIColor = .clear
    
    private let contentLabel = BKLabel(
        fontStyle: .label1(weight: .semiBold),
        highlightedWord: "______",
        highlightColor: UIColor(hex: "D6D6D6")
    )
    
    var onSelected: ((AppreciationGuide) -> Void)?
    
    override var isSelected: Bool {
        didSet {
            updateStyle()
        }
    }
    
    private let guide: AppreciationGuide
    
    init(guide: AppreciationGuide) {
        self.guide = guide
        super.init(frame: .zero)
        setupStyle()
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStyle() {
        layer.cornerRadius = LayoutConstants.cornerRadius
        layer.borderWidth = LayoutConstants.borderWidth
        addSubview(contentLabel)
        contentLabel.setText(text: guide.reaction)
        contentLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
                .inset(LayoutConstants.labelInset)
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.labelInset)
            $0.trailing.lessThanOrEqualToSuperview()
                .inset(LayoutConstants.labelInset)
        }
        
        updateStyle()
    }
    
    private func updateStyle() {
        layer.borderColor = (isSelected ? selectedBorderColor : deselectedBorderColor).cgColor
        backgroundColor = isSelected ? selectedBackgroundColor : deselectedBackgroundColor
    }
    
    @objc private func buttonTapped() {
        isSelected = true
        onSelected?(guide)
    }
}

private extension AppreciationGuideButton {
    enum LayoutConstants {
        static let cornerRadius = BKRadius.small
        static let borderWidth = BKBorder.border1
        static let labelInset = BKInset.inset4
    }
}

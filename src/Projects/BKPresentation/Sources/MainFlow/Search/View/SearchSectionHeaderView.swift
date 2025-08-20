// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class SearchSectionHeaderView: UIView {
    private var heightConstraint: Constraint?
    private let titleLabel = BKLabel()
    
    enum SearchSectionHeaderType {
        case recent
        case result(count: Int)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        snp.makeConstraints {
            heightConstraint = $0.height.equalTo(LayoutConstants.selfHeight).constraint
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.leadingInset).priority(.low)
            $0.top.bottom.equalToSuperview()
                .inset(LayoutConstants.verticalInset).priority(.low)
        }
        setTitle(.recent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ type: SearchSectionHeaderType) {
        switch type {
        case .recent:
            titleLabel.isHidden = false
            heightConstraint?.update(offset: LayoutConstants.selfHeight)
            titleLabel.setFontStyle(style: .body1(weight: .semiBold))
            titleLabel.setText(text: "최근 검색어")
        case .result(let count):
            // swiftlint:disable:next empty_count
            if count > 0 {
                titleLabel.isHidden = false
                titleLabel.setAttributedText(
                    with: makeResultString(
                        count: count
                    )
                )
                heightConstraint?.update(offset: LayoutConstants.selfHeight)
            } else {
                titleLabel.isHidden = true
                heightConstraint?.update(offset: 0)
            }
        }
    }
}

private extension SearchSectionHeaderView {
    func makeResultString(count: Int) -> NSAttributedString {
        let fullText = "총 \(count)개"
        let countString = "\(count)"

        let baseFont = BKTextStyle.label1(weight: .medium).uiFont ?? UIFont.systemFont(ofSize: 14)
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: baseFont,
                .foregroundColor: UIColor.black
            ]
        )

        if let range = fullText.range(of: countString) {
            let nsRange = NSRange(range, in: fullText)
            attributed.addAttribute(
                .foregroundColor,
                value: UIColor.bkContentColor(.brand),
                range: nsRange
            )
        }
        
        return attributed
    }
    
    enum LayoutConstants {
        static let verticalInset: CGFloat = 8
        static let leadingInset: CGFloat = 20
        static let selfHeight: CGFloat = 42
    }
}

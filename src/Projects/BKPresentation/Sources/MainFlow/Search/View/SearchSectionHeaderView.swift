// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class SearchSectionHeaderView: UIView {
    private let titleLabel = BKLabel()
    
    enum SearchSectionHeaderType {
        case recent
        case result(count: Int)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.leadingInset)
            $0.top.bottom.equalToSuperview()
                .inset(LayoutConstants.verticalInset)
        }
        setTitle(.recent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ type: SearchSectionHeaderType) {
        switch type {
        case .recent:
            isHidden = false
            titleLabel.setFontStyle(style: .body1(weight: .semiBold))
            titleLabel.setText(text: "최근 검색어")
        case .result(let count):
            // swiftlint:disable:next empty_count
            isHidden = count == 0
            // swiftlint:disable:next empty_count
            if count > 0 {
                titleLabel.setAttributedText(
                    with: makeResultString(
                        count: count
                    )
                )
            }
        }
    }
}

private extension SearchSectionHeaderView {
    func makeResultString(count: Int) -> NSAttributedString {
        let fullText = "총 \(count)개"
        let countString = "\(count)"

        let baseFont = BKTextStyle.body1(weight: .semiBold).uiFont ?? UIFont.systemFont(ofSize: 14)
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
    }
}

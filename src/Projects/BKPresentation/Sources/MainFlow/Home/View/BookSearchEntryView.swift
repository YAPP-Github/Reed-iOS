// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class BookSearchEntryView: UIView {
    private let title = BKLabel(
        text: "책 등록하기",
        fontStyle: .body2(weight: .medium),
        color: .bkContentColor(.brand)
    )
    
    private let iconImage = UIImageView(image: BKImage.Icon.chevronRight)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setLayout()
    }

    private func setLayout() {
        iconImage.tintColor = UIColor.bkContentColor(.brand)
        
        addSubviews(title, iconImage)
        
        title.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        
        iconImage.snp.makeConstraints {
            $0.leading.equalTo(title.snp.trailing).offset(BKSpacing.spacing1)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
    }
}

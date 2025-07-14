// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

enum TermsViewEvent {
    
}

final class TermsView: BaseView {
    
    private let titleLabel = BKLabel(
        text: "약관 동의 후\n독서 기록을 남겨보세요",
        fontStyle: .title2(weight: .semiBold),
        alignment: .left
    )
    
    override func setupView() {
        titleLabel.numberOfLines = 2
        
        addSubviews(titleLabel)
    }
    
}

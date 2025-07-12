// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

final class BKBottomSheetTitleTestView: BaseView {

    private let stackView = UIStackView()

    override func setupView() {
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
    }

    override func setupLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
    }

    override func configure() {
        let styles: [BKBottomSheetTitleStyle] = [
            .none,
            .title("타이틀만"),
            .titleWithCloseButton(title: "타이틀 + 닫기"),
            .titleWithSubtitle(title: "타이틀", subtitle: "서브타이틀만"),
            .titleWithSubtitleAndCloseButton(title: "타이틀", subtitle: "서브타이틀 + 닫기")
        ]

        styles.forEach { style in
            let titleView = BKBottomSheetTitleView(style: style)
            titleView.backgroundColor = UIColor.white
            
            titleView.snp.makeConstraints { make in
                make.height.lessThanOrEqualTo(54)
            }
            stackView.addArrangedSubview(titleView)
        
        }
    }
}

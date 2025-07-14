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
        stackView.alignment = .leading
    }

    override func setupLayout() {
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    override func configure() {
        [
            BKBottomSheetTitleView(
                style: .centered,
                title: "Centered with subtitle",
                subtitle: "subtitle"
            ),
            BKBottomSheetTitleView(
                style: .centered,
                title: "Centered without subtitle",
                subtitle: nil
            ),
            BKBottomSheetTitleView(
                style: .leadingCloseButton,
                title: "Leading with subtitle",
                subtitle: "subtitle"
            ),
            BKBottomSheetTitleView(
                style: .leadingCloseButton,
                title: "Leading without subtitle",
                subtitle: nil
            )
        ].forEach { titleView in
            stackView.addArrangedSubview(titleView)
        }
    }
}

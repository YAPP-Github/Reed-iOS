// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

extension BKBottomSheetViewController {
    private class OptionTapGesture: UITapGestureRecognizer {
        let option: SortOption
        let confirmAction: (SortOption) -> Void

        init(option: SortOption, confirmAction: @escaping (SortOption) -> Void) {
            self.option = option
            self.confirmAction = confirmAction
            super.init(target: nil, action: nil)
            addTarget(self, action: #selector(handleTap))
        }

        @objc private func handleTap() {
            confirmAction(option)
        }
    }

    static func makeBookDetailSortMenuSheet(
        selectedOption: SortOption,
        confirmAction: @escaping (SortOption) -> Void
    ) -> BKBottomSheetViewController {
        let containerView = UIView()
        let divider = BKDivider(type: .small)
        let newestOption = makeOptionView(option: .newest, confirmAction: confirmAction)
        let pageDescendingOption = makeOptionView(option: .pageDescending, confirmAction: confirmAction)
        
        let stackView = UIStackView(arrangedSubviews: [newestOption, divider, pageDescendingOption])
        stackView.axis = .vertical
        stackView.spacing = 0
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(BKInset.inset3)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        let sheet = BKBottomSheetViewController(
            title: "정렬",
            style: .leadingCloseButton,
            suppliedContentStyle: .lower(containerView)
        )
        
        return sheet
    }
    
    private static func makeOptionView(
        option: SortOption,
        confirmAction: @escaping (SortOption) -> Void
    ) -> UIView {
        let containerView = UIView()
        let titleLabel = BKLabel(
            text: option.rawValue,
            fontStyle: .body1(weight: .medium),
            color: .bkContentColor(.primary)
        )
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
                .inset(BKInset.inset6)
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        let tapGesture = OptionTapGesture(option: option, confirmAction: confirmAction)
        containerView.isUserInteractionEnabled = true
        containerView.addGestureRecognizer(tapGesture)
        
        return containerView
    }
}

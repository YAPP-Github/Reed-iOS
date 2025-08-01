// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

extension BKBottomSheetViewController {
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
    
    static func makeAppreciationGuideSheet(
        confirmAction: @escaping (AppreciationGuide) -> Void
    ) -> BKBottomSheetViewController {
        var selectedGuide: AppreciationGuide?
        let guideButtons = AppreciationGuide.allCases.map {
            AppreciationGuideButton(guide: $0)
        }
        
        let containerView = UIView()
        let guideStack = UIStackView(arrangedSubviews: guideButtons)
        guideStack.axis = .vertical
        guideStack.spacing = BKSpacing.spacing2
        
        let sheet = BKBottomSheetViewController(
            title: "감상평 가이드",
            subtitle: "아래 문장 중 하나를 선택해 이어서 감상을 적어보세요",
            style: .leadingCloseButton,
            suppliedContentStyle: .lower(containerView),
            buttonConfiguration: .singleFullButton(
                title: "선택 완료",
                action: {
                    guard let selectedGuide else { return }
                    confirmAction(selectedGuide)
                }
            )
        )
        containerView.addSubview(guideStack)
        guideStack.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
                .inset(BKInset.inset5)
            $0.horizontalEdges.equalToSuperview()
        }
        
        guideButtons.forEach { button in
            button.onSelected = { selected in
                selectedGuide = selected
                guideButtons.forEach { $0.isSelected = ($0 == button) }
                sheet.button?.setPrimaryButtonState(true)
            }
        }
        
        sheet.button?.setPrimaryButtonState(false)
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
}

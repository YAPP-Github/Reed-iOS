// Copyright © 2025 Booket. All rights reserved

import BKDesign
import SnapKit
import UIKit

extension BKBottomSheetViewController {
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
}

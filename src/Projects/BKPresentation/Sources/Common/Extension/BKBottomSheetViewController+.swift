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
        let newestOption = makeOptionView(
            option: .newest,
            isSelected: selectedOption == .newest,
            confirmAction: confirmAction
        )
        let pageDescendingOption = makeOptionView(
            option: .pageDescending,
            isSelected: selectedOption == .pageDescending,
            confirmAction: confirmAction
        )
        
        containerView.addSubviews(pageDescendingOption, divider, newestOption)
        
        pageDescendingOption.snp.makeConstraints {
            $0.top.equalToSuperview().inset(BKInset.inset3)
            $0.leading.trailing.equalToSuperview()
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(pageDescendingOption.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(-BKSpacing.spacing5)
        }
        
        newestOption.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
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
    
    static func makeMoreMenuSheet(
        onShare: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> BKBottomSheetViewController {
        let menuStack = UIStackView()
        menuStack.axis = .vertical
        menuStack.spacing = 0
        
        let shareMenuView = makeMenuItemView(
            icon: BKImage.Icon.share,
            title: "공유하기",
            color: .bkContentColor(.primary),
            action: onShare
        )
        
        let editMenuView = makeMenuItemView(
            icon: BKImage.Icon.edit,
            title: "수정하기",
            color: .bkContentColor(.primary),
            action: onEdit
        )
        
        let deleteMenuView = makeMenuItemView(
            icon: BKImage.Icon.trash,
            title: "삭제하기",
            color: .bkContentColor(.error),
            action: onDelete
        )
        
        menuStack.addArrangedSubview(shareMenuView)
        menuStack.addArrangedSubview(editMenuView)
        menuStack.addArrangedSubview(deleteMenuView)
        
        let sheet = BKBottomSheetViewController(
            style: .contentOnly,
            suppliedContentStyle: .lower(menuStack)
        )
        
        return sheet
    }
    
    static func makeDeleteOnlyMenuSheet(
        onDelete: @escaping () -> Void
    ) -> BKBottomSheetViewController {
        let deleteMenuView = makeMenuItemView(
            icon: BKImage.Icon.trash.withTintColor(.bkContentColor(.error)),
            title: "삭제하기",
            color: .bkContentColor(.error),
            action: onDelete
        )
        
        let sheet = BKBottomSheetViewController(
            style: .contentOnly,
            suppliedContentStyle: .lower(deleteMenuView)
        )
        
        return sheet
    }
    
    private static func makeMenuItemView(
        icon: UIImage,
        title: String,
        color: UIColor,
        action: @escaping () -> Void
    ) -> UIView {
        let menuView = UIView()
        let iconImageView = UIImageView(image: icon.withRenderingMode(.alwaysTemplate))
        let titleLabel = BKLabel(
            text: title,
            fontStyle: .body1(weight: .medium),
            color: color
        )
        
        iconImageView.tintColor = color
        menuView.addSubviews(iconImageView, titleLabel)
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(BKInset.inset6)
            $0.size.equalTo(CGSize(width: 20, height: 20))
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(BKInset.inset3)
            $0.top.bottom.equalToSuperview().inset(BKInset.inset5)
        }
        
        menuView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(
            BKBottomSheetMenuActionTarget.shared,
            action: #selector(BKBottomSheetMenuActionTarget.handleTap)
        )
        menuView.addGestureRecognizer(tapGesture)
        
        // 액션을 저장
        BKBottomSheetMenuActionTarget.shared.setAction(for: menuView, action: action)
        
        return menuView
    }
    
    private static func makeOptionView(
        option: SortOption,
        isSelected: Bool,
        confirmAction: @escaping (SortOption) -> Void
    ) -> UIView {
        let containerView = UIView()
        let titleLabel = BKLabel(
            text: option.rawValue,
            fontStyle: .body1(weight: .medium),
            color: isSelected ? .bkContentColor(.brand) : .bkContentColor(.secondary)
        )
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
                .inset(BKInset.inset1)
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

fileprivate class BKBottomSheetMenuActionTarget {
    static let shared = BKBottomSheetMenuActionTarget()
    private var actions: [UIView: () -> Void] = [:]

    func setAction(for view: UIView, action: @escaping () -> Void) {
        actions[view] = action
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        actions[view]?()
    }
}

// MARK: - DetailEmotion Selection BottomSheet

import BKDomain

extension BKBottomSheetViewController {
    static func makeDetailEmotionSheet(
        primaryEmotion: PrimaryEmotion,
        detailEmotions: [DetailEmotion],
        initialSelectedDetailEmotions: [DetailEmotion] = [],
        skipAction: @escaping () -> Void,
        confirmAction: @escaping ([DetailEmotion]) -> Void
    ) -> BKBottomSheetViewController {
        var selectedDetailEmotions: Set<DetailEmotion> = Set(initialSelectedDetailEmotions)

        let containerView = UIView()

        // Chip들을 담을 FlowLayout 스택뷰
        let chipContainerView = UIView()
        var chipViews: [BKChip] = []

        let sheet = BKBottomSheetViewController(
            title: "어떤 '\(primaryEmotion.displayName)'을 느꼈나요?",
            subtitle: "더 자세한 감정을 선택 기록할 수 있어요.",
            style: .leadingCloseButton,
            suppliedContentStyle: .lower(containerView),
            buttonConfiguration: .twoButtonGroup(
                leftTitle: "건너뛰기",
                rightTitle: "선택 완료",
                leftAction: skipAction,
                rightAction: {
                    confirmAction(Array(selectedDetailEmotions))
                }
            )
        )

        // Chip 생성
        for detailEmotion in detailEmotions {
            let chip = BKChip(title: detailEmotion.name)
            // 초기 선택 상태 설정
            if initialSelectedDetailEmotions.contains(where: { $0.id == detailEmotion.id }) {
                chip.isSelected = true
            }
            chip.onTap = { [weak sheet] in
                if selectedDetailEmotions.contains(detailEmotion) {
                    selectedDetailEmotions.remove(detailEmotion)
                    chip.isSelected = false
                } else {
                    selectedDetailEmotions.insert(detailEmotion)
                    chip.isSelected = true
                }
                // 1개 이상 선택되어야 버튼 활성화
                sheet?.button?.setPrimaryButtonState(!selectedDetailEmotions.isEmpty)
            }
            chipViews.append(chip)
        }

        containerView.addSubview(chipContainerView)

        chipContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(BKInset.inset5)
        }

        // Chip들을 FlowLayout처럼 배치
        layoutChips(chipViews, in: chipContainerView)

        // 초기 선택 상태에 따라 버튼 활성화
        sheet.button?.setPrimaryButtonState(!selectedDetailEmotions.isEmpty)
        return sheet
    }

    private static func layoutChips(_ chips: [BKChip], in containerView: UIView) {
        let flowLayoutView = CenteredFlowLayoutView()
        flowLayoutView.setChips(chips)

        containerView.addSubview(flowLayoutView)
        flowLayoutView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - CenteredFlowLayoutView

private final class CenteredFlowLayoutView: UIView {
    private var chipViews: [UIView] = []
    private let horizontalSpacing: CGFloat = 8
    private let verticalSpacing: CGFloat = 8

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setChips(_ views: [UIView]) {
        chipViews.forEach { $0.removeFromSuperview() }
        chipViews = views
        chipViews.forEach { addSubview($0) }
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let maxWidth = bounds.width
        guard maxWidth > 0 else { return }

        // 각 칩의 크기를 먼저 계산
        let chipSizes = chipViews.map { $0.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) }

        // 줄별로 칩을 그룹화
        var rows: [[Int]] = []
        var currentRow: [Int] = []
        var currentRowWidth: CGFloat = 0

        for (index, chipSize) in chipSizes.enumerated() {
            let chipWidth = chipSize.width
            let neededWidth = currentRow.isEmpty ? chipWidth : horizontalSpacing + chipWidth

            if currentRowWidth + neededWidth > maxWidth, !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [index]
                currentRowWidth = chipWidth
            } else {
                currentRow.append(index)
                currentRowWidth += neededWidth
            }
        }
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        // 각 줄을 중앙 정렬하여 배치
        var currentY: CGFloat = 0

        for row in rows {
            let rowWidth = row.reduce(CGFloat(0)) { total, index in
                total + chipSizes[index].width
            } + CGFloat(max(0, row.count - 1)) * horizontalSpacing

            var currentX = (maxWidth - rowWidth) / 2
            var rowHeight: CGFloat = 0

            for index in row {
                let chipSize = chipSizes[index]
                chipViews[index].frame = CGRect(
                    x: currentX,
                    y: currentY,
                    width: chipSize.width,
                    height: chipSize.height
                )
                currentX += chipSize.width + horizontalSpacing
                rowHeight = max(rowHeight, chipSize.height)
            }

            currentY += rowHeight + verticalSpacing
        }

        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        let maxWidth = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width - 40

        let chipSizes = chipViews.map { $0.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) }

        var rows: [[Int]] = []
        var currentRow: [Int] = []
        var currentRowWidth: CGFloat = 0

        for (index, chipSize) in chipSizes.enumerated() {
            let chipWidth = chipSize.width
            let neededWidth = currentRow.isEmpty ? chipWidth : horizontalSpacing + chipWidth

            if currentRowWidth + neededWidth > maxWidth, !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [index]
                currentRowWidth = chipWidth
            } else {
                currentRow.append(index)
                currentRowWidth += neededWidth
            }
        }
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }

        var totalHeight: CGFloat = 0
        for row in rows {
            let rowHeight = row.map { chipSizes[$0].height }.max() ?? 0
            totalHeight += rowHeight
        }
        totalHeight += CGFloat(max(0, rows.count - 1)) * verticalSpacing

        return CGSize(width: UIView.noIntrinsicMetric, height: totalHeight)
    }
}

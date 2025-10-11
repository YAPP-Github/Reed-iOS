// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import SnapKit
import UIKit

final class SeedReportView: BaseView {
    private let titleLabel = BKLabel(
        text: "내가 모은 씨앗",
        fontStyle: .body2(weight: .medium),
        color: .bkContentColor(.secondary)
    )
    
    private var emotionReport: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    private let reportLabel = BKLabel(
        fontStyle: .label2(weight: .regular),
        color: .bkContentColor(.secondary),
        highlightColor: .bkContentColor(.brand),
        highlightFont: BKTextStyle.label2(weight: .semiBold).uiFont
    )
    
    private let reportContainer = UIView()
    
    override func setupView() {
        addSubviews(titleLabel, emotionReport, reportContainer)
        reportContainer.addSubview(reportLabel)
    }
    
    override func configure() {
        layer.cornerRadius = LayoutConstants.cornerRadius
        clipsToBounds = true
        backgroundColor = .bkBaseColor(.secondary)
        reportContainer.backgroundColor = .bkBaseColor(.primary)
        reportContainer.layer.borderWidth = LayoutConstants.reportContainerBorderWidth
        reportContainer.layer.cornerRadius = LayoutConstants.reportContainerCornerRadius
        reportContainer.layer.borderColor = UIColor.bkBorderColor(.primary).cgColor
        reportContainer.clipsToBounds = true
    }
    
    override func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.trailing.leading.equalToSuperview()
                .inset(LayoutConstants.contentInset)
        }
        
        emotionReport.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(LayoutConstants.contentSpacing)
            $0.height.equalTo(LayoutConstants.emotionReportHeight)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.contentInset * 2)
        }
        
        reportContainer.snp.makeConstraints {
            $0.top.equalTo(emotionReport.snp.bottom)
                .offset(LayoutConstants.contentSpacing)
            $0.leading.trailing.bottom.equalToSuperview()
                .inset(LayoutConstants.contentInset)
            $0.height.equalTo(42)
        }
        
        reportLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func applyReport(with seeds: [Seed]) {
        var counts: [EmotionSeed: Int] = [:]
        for s in seeds {
            if let key = EmotionSeed.from(seed: s) {
                counts[key, default: 0] += s.count
            }
        }
        applyReportCore(counts: counts)
    }
}

private extension SeedReportView {
    func applyReportCore(counts: [EmotionSeed: Int]) {
        emotionReport.arrangedSubviews.forEach {
            emotionReport.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for seed in EmotionSeed.allCases {
            let count = counts[seed] ?? 0
            emotionReport.addArrangedSubview(makeInnerView(with: seed, count: count))
        }

        let (summary, highlightedWord) = generateEmotionSummary(from: counts)
        reportLabel.setText(text: summary)
        reportLabel.highlightedWord = highlightedWord
    }
    
    func generateEmotionSummary(
        from counts: [EmotionSeed: Int]
    ) -> (String, String) {
        let sorted = EmotionSeed.allCases
            .map { ($0, counts[$0] ?? 0) }
            .sorted { $0.1 > $1.1 }
        
        guard let maxCount = sorted.first?.1, maxCount > 0 else {
            return ("감정 데이터가 부족해요.", "")
        }
        
        let top = sorted.filter { $0.1 == maxCount }.map { $0.0 }
        if top.count >= 3 {
            return ("이 책에서 여러 감정이 고르게 담겼어요", "여러 감정이 고르게 담겼어요")
        } else {
            let names = top.map { $0.rawValue }.joined(separator: ", ")
            return ("이 책에서 \(names) 감정을 많이 느꼈어요", names)
        }
    }
    
    func makeInnerView(
        with emotion: EmotionSeed,
        count: Int
    ) -> UIView {
        let containerView = UIView()
        let imageView = UIImageView(image: emotion.image)
        let labelContainer = UIView()
        let emotionLabel = BKLabel(
            text: emotion.rawValue,
            fontStyle: .label2(weight: .semiBold),
            color: emotion.color
        )
        labelContainer.backgroundColor = emotion.baseColor
        labelContainer.layer.cornerRadius = LayoutConstants.labelContainerCornerRadius
        labelContainer.clipsToBounds = true
        let countLabel = BKLabel(
            text: "\(count)",
            fontStyle: .label2(weight: .regular),
            color: .bkContentColor(.secondary)
        )
        
        containerView.addSubviews(imageView, labelContainer, countLabel)
        labelContainer.addSubview(emotionLabel)
        
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.size.equalTo(LayoutConstants.imageSize)
        }
        
        labelContainer.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
                .offset(LayoutConstants.labelContainerOffset)
            $0.height.equalTo(LayoutConstants.labelContainerHeight)
            $0.centerX.equalToSuperview()
        }
        
        emotionLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.emotionLabelHorizontalInset)
            $0.verticalEdges.equalToSuperview()
                .inset(LayoutConstants.emotionLabelVerticalInset)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalTo(labelContainer.snp.bottom)
                .offset(LayoutConstants.countLabelOffset)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        return containerView
    }
}

private extension SeedReportView {
    enum LayoutConstants {
        static let contentInset = BKInset.inset4
        static let contentSpacing = BKSpacing.spacing5
        static let cornerRadius = BKRadius.medium
        static let reportLabelVerticalInset = BKInset.inset3
        static let reportContainerBorderWidth = BKBorder.border1
        static let reportContainerCornerRadius = BKRadius.small
        static let labelContainerHeight: CGFloat = 24
        static let labelContainerCornerRadius: CGFloat = labelContainerHeight / 2
        static let imageSize: CGSize = CGSize(width: 50, height: 50)
        static let labelContainerOffset = BKInset.inset2
        static let countLabelOffset = BKInset.inset1
        static let emotionLabelHorizontalInset = BKInset.inset2
        static let emotionLabelVerticalInset = BKInset.inset1
        static let emotionReportHeight: CGFloat = 106
    }
}

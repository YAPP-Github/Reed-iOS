// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import SnapKit
import UIKit

final class SeedReportView: BaseView {
    // MARK: - Properties
    private var isExpanded = false

    // MARK: - UI Components
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        return stackView
    }()

    private let headerView = UIView()
    private let emotionImageView = UIImageView()

    private let reportLabel = BKLabel2(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.secondary),
        highlightColor: .bkContentColor(.brand),
        highlightFont: BKTextStyle.label1(weight: .semiBold).uiFont
    )

    private let foldButton: UIImageView = {
        let imageView = UIImageView(
            image: BKImage.Icon.chevronDown
                .withRenderingMode(.alwaysTemplate)
        )
        imageView.tintColor = .bkContentColor(.tertiary)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let divider = BKDivider(type: .small)

    private let expandedView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.alpha = 0
        return view
    }()

    private let graphView = SeedGraphView()

    private let labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 4
        return stackView
    }()

    override func setupView() {
        addSubview(containerStackView)

        headerView.addSubviews(emotionImageView, reportLabel, foldButton)
        [headerView, expandedView].forEach(containerStackView.addArrangedSubview)
        expandedView.addSubviews(divider, graphView, labelsStackView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleExpansion))
        foldButton.addGestureRecognizer(tapGesture)
    }

    override func configure() {
        layer.cornerRadius = LayoutConstants.cornerRadius
        clipsToBounds = true
        backgroundColor = .bkBaseColor(.secondary)
    }

    override func setupLayout() {
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(LayoutConstants.contentInset)
        }

        headerView.snp.makeConstraints {
            $0.height.equalTo(LayoutConstants.emotionStackHeight)
        }

        emotionImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(
                CGSize(
                    width: LayoutConstants.emotionStackHeight,
                    height: LayoutConstants.emotionStackHeight
                )
            )
        }

        reportLabel.snp.makeConstraints {
            $0.leading
                .equalTo(emotionImageView.snp.trailing)
                .offset(LayoutConstants.labelLeadingInset)
            $0.centerY.equalToSuperview()
        }

        foldButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(LayoutConstants.iconSize)
        }

        divider.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }

        graphView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(LayoutConstants.graphTopOffset)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(LayoutConstants.graphHeight)
        }

        labelsStackView.snp.makeConstraints {
            $0.top.equalTo(graphView.snp.bottom).offset(LayoutConstants.labelsTopOffset)
            $0.height.equalTo(72)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    func setEmotionHeader(with emotion: Emotion) {
        guard let emotion = EmotionSeed.from(emotion: emotion) else { return }
        let emotionText = "\'\(emotion.rawValue)\'"
        emotionImageView.image = emotion.circleImage
        reportLabel.highlightColor = emotion.color
        reportLabel.setText(text: "\(emotionText) \(emotion.descriptionText)")
        reportLabel.highlightedWord = emotionText
    }

    func applyGraph(with seeds: [Seed]) {
        graphView.applyGraph(with: seeds)

        labelsStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        let seedDict = Dictionary(seeds.map { ($0.name, $0) }, uniquingKeysWith: { first, last in last })

        EmotionSeed.allCases.forEach { emotionCase in
            if let seed = seedDict[emotionCase.rawValue], seed.count >= 1 {
                let itemView = SeedItemView()
                itemView.configure(with: seed)
                labelsStackView.addArrangedSubview(itemView)
            }
        }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

private extension SeedReportView {
    @objc private func toggleExpansion() {
        isExpanded.toggle()

        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.expandedView.isHidden = !self.isExpanded
            self.expandedView.alpha = self.isExpanded ? 1 : 0

            let angle: CGFloat = self.isExpanded ? .pi : 0
            self.foldButton.transform = CGAffineTransform(rotationAngle: angle)

            self.layoutIfNeeded()
        }
    }
}

private extension SeedReportView {
    enum LayoutConstants {
        static let contentInset = BKInset.inset4
        static let cornerRadius = BKRadius.medium
        static let emotionStackHeight = 36
        static let labelLeadingInset = BKSpacing.spacing2
        static let iconSize: CGSize = CGSize(width: 24, height: 24)

        static let graphHeight: CGFloat = 12
        static let graphTopOffset: CGFloat = BKSpacing.spacing5
        static let labelsTopOffset: CGFloat = BKSpacing.spacing4
    }
}

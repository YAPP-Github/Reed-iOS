// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import SnapKit
import UIKit

final class AppreciationResultView: BaseView {
    private let containerView = UIView()

    private let titleLabel = BKLabel(
        text: "감상평 기록",
        fontStyle: .body1(weight: .medium),
        color: .bkContentColor(.primary)
    )

    private let rootStackBackgroundView = UIView()
    private let rootStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = LayoutConstants.rootStackSpacing
        stackView.alignment = .fill
        return stackView
    }()

    // 감상평 텍스트
    private let appreciationLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.primary)
    )

    // 하단 컨테이너 (감정 정보 + 날짜) - UIView로 변경하여 유연한 레이아웃
    private let bottomContainerView = UIView()

    // 감정 아이콘
    private let emotionIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = LayoutConstants.emotionIconSize / 2
        return imageView
    }()

    // 대표 감정 뱃지
    private let emotionBadge: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    private let emotionBadgeLabel = BKLabel(
        fontStyle: .label2(weight: .semiBold),
        color: .bkContentColor(.brand)
    )

    // 세부 감정 태그들 (FlowLayout)
    private let detailEmotionTagsView = TagFlowView()

    // 날짜
    private let creationLabel = BKLabel(
        fontStyle: .label2(weight: .regular),
        color: .bkContentColor(.tertiary),
        alignment: .right
    )

    override func setupView() {
        addSubview(containerView)

        // 뱃지 구성
        emotionBadge.addArrangedSubview(emotionBadgeLabel)

        // 하단 컨테이너에 요소들 추가
        bottomContainerView.addSubviews(
            emotionIcon,
            emotionBadge,
            detailEmotionTagsView,
            creationLabel
        )

        // 루트 스택 (감상평 + 하단 컨테이너)
        [appreciationLabel, bottomContainerView].forEach(rootStack.addArrangedSubview(_:))

        rootStackBackgroundView.addSubview(rootStack)
        containerView.addSubviews(titleLabel, rootStackBackgroundView)
    }

    override func configure() {
        appreciationLabel.numberOfLines = 0
        rootStackBackgroundView.backgroundColor = UIColor.bkBaseColor(.secondary)
        rootStackBackgroundView.layer.cornerRadius = LayoutConstants.rootStackRadius
        emotionBadge.backgroundColor = UIColor.bkBackgroundColor(.tertiary)
        emotionBadge.clipsToBounds = true
    }

    override func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        rootStackBackgroundView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(LayoutConstants.rootStackTopOffset)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        rootStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
                .inset(LayoutConstants.rootStackInset)
        }

        // 감정 아이콘
        emotionIcon.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.size.equalTo(LayoutConstants.emotionIconSize)
        }

        // 대표 감정 뱃지 (기본: emotionIcon 중앙 정렬, 세부 감정 있으면 상단 정렬로 변경)
        emotionBadge.snp.makeConstraints {
            $0.leading.equalTo(emotionIcon.snp.trailing).offset(LayoutConstants.emotionContainerSpacing)
            $0.centerY.equalTo(emotionIcon)
        }

        // 날짜 (trailing 고정, 기본 centerY는 emotionIcon 기준)
        creationLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(emotionIcon)
        }

        // 세부 감정 태그 (뱃지 아래, trailing은 날짜와 16px 간격)
        detailEmotionTagsView.snp.makeConstraints {
            $0.leading.equalTo(emotionBadge)
            $0.top.equalTo(emotionBadge.snp.bottom).offset(LayoutConstants.emotionInfoSpacing)
            $0.trailing.equalTo(creationLabel.snp.leading).offset(-LayoutConstants.minSpacingToDate)
        }

        // 하단 컨테이너 높이 (아이콘 또는 태그 중 큰 쪽)
        bottomContainerView.snp.makeConstraints {
            $0.bottom.greaterThanOrEqualTo(emotionIcon)
            $0.bottom.greaterThanOrEqualTo(detailEmotionTagsView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // emotionBadge의 레이아웃을 먼저 확정시킨 후 cornerRadius 적용
        emotionBadge.layoutIfNeeded()
        // pill 형태 (양 끝이 완전한 원형)
        emotionBadge.layer.cornerRadius = emotionBadge.bounds.height / 2
    }

    func apply(
        emotion: PrimaryEmotion,
        detailEmotions: [DetailEmotion] = [],
        creationDate: Date,
        appreciation: String? = ""
    ) {
        // 감정 아이콘 (원형 이미지)
        emotionIcon.image = emotion.noteImage

        // 대표 감정 뱃지
        emotionBadgeLabel.setText(text: emotion.displayName)
        emotionBadge.isHidden = false

        // 기타 감정일 때 칩 색상 변경
        if emotion == .other {
            emotionBadge.backgroundColor = BKAtomicColor.Neutral.n200.color
            emotionBadgeLabel.setColor(color: BKAtomicColor.Neutral.n400.color)
        } else {
            emotionBadge.backgroundColor = UIColor.bkBackgroundColor(.tertiary)
            emotionBadgeLabel.setColor(color: UIColor.bkContentColor(.brand))
        }

        // 세부 감정 태그들
        updateDetailEmotionTags(detailEmotions)

        // 날짜 위치 업데이트 (세부 감정 유무에 따라 다름)
        updateCreationLabelPosition(hasDetailEmotions: !detailEmotions.isEmpty)

        // 날짜
        creationLabel.setText(text: creationDate.toKoreanDotDateString())

        // 감상평
        if let review = appreciation, !review.isEmpty {
            appreciationLabel.setText(text: review)
            appreciationLabel.isHidden = false
            rootStack.spacing = LayoutConstants.rootStackSpacing
        } else {
            appreciationLabel.isHidden = true
            rootStack.spacing = 0
        }
    }

    private func updateDetailEmotionTags(_ detailEmotions: [DetailEmotion]) {
        guard !detailEmotions.isEmpty else {
            detailEmotionTagsView.isHidden = true
            return
        }

        detailEmotionTagsView.isHidden = false
        let tags = detailEmotions.map { "#\($0.name)" }
        detailEmotionTagsView.setTags(tags)
    }

    /// 세부 감정 유무에 따라 레이아웃 업데이트
    /// - 세부 감정 없음: 뱃지와 날짜 모두 emotionIcon의 centerY에 맞춤 (중앙 정렬)
    /// - 세부 감정 있음: 뱃지는 상단 정렬, 날짜는 태그 하단에 맞춤
    private func updateCreationLabelPosition(hasDetailEmotions: Bool) {
        // 대표 감정 뱃지 위치 업데이트
        emotionBadge.snp.remakeConstraints {
            $0.leading.equalTo(emotionIcon.snp.trailing).offset(LayoutConstants.emotionContainerSpacing)
            if hasDetailEmotions {
                $0.top.equalToSuperview()
            } else {
                $0.centerY.equalTo(emotionIcon)
            }
        }

        // 날짜 위치 업데이트
        creationLabel.snp.remakeConstraints {
            $0.trailing.equalToSuperview()
            if hasDetailEmotions {
                $0.bottom.equalTo(detailEmotionTagsView)
            } else {
                $0.centerY.equalTo(emotionIcon)
            }
        }
    }
}

// MARK: - TagFlowView

/// 태그들을 FlowLayout으로 배치하는 뷰
/// - 가로로 배치하다가 공간이 부족하면 다음 줄로
/// - 태그가 중간에 끊기지 않음
private final class TagFlowView: UIView {
    private var tagLabels: [BKLabel] = []
    private let horizontalSpacing: CGFloat = 8
    private let verticalSpacing: CGFloat = 4

    func setTags(_ tags: [String]) {
        // 기존 태그 제거
        tagLabels.forEach { $0.removeFromSuperview() }
        tagLabels.removeAll()

        // 새 태그 생성
        for tag in tags {
            let label = BKLabel(
                fontStyle: .caption1(weight: .regular),
                color: .bkContentColor(.tertiary)
            )
            label.setText(text: tag)
            addSubview(label)
            tagLabels.append(label)
        }

        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutTags()
    }

    private func layoutTags() {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for label in tagLabels {
            label.sizeToFit()
            let labelWidth = label.bounds.width
            let labelHeight = label.bounds.height

            // 현재 줄에 맞지 않으면 다음 줄로
            if x + labelWidth > bounds.width && x > 0 {
                x = 0
                y += lineHeight + verticalSpacing
                lineHeight = 0
            }

            label.frame = CGRect(x: x, y: y, width: labelWidth, height: labelHeight)
            x += labelWidth + horizontalSpacing
            lineHeight = max(lineHeight, labelHeight)
        }

        // 높이가 변경되면 intrinsicContentSize 업데이트
        let newHeight = y + lineHeight
        if abs(newHeight - bounds.height) > 1 {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        guard !tagLabels.isEmpty else {
            return CGSize(width: UIView.noIntrinsicMetric, height: 0)
        }

        // 너비가 아직 결정되지 않았으면 기본값 사용
        let availableWidth = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width - 100

        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for label in tagLabels {
            label.sizeToFit()
            let labelWidth = label.bounds.width
            let labelHeight = label.bounds.height

            if x + labelWidth > availableWidth && x > 0 {
                x = 0
                y += lineHeight + verticalSpacing
                lineHeight = 0
            }

            x += labelWidth + horizontalSpacing
            lineHeight = max(lineHeight, labelHeight)
        }

        return CGSize(width: UIView.noIntrinsicMetric, height: y + lineHeight)
    }
}

// MARK: - LayoutConstants

private extension AppreciationResultView {
    enum LayoutConstants {
        static let rootStackSpacing = BKSpacing.spacing5
        static let rootStackTopOffset = BKInset.inset2
        static let rootStackInset = BKInset.inset4
        static let rootStackRadius = BKRadius.medium
        static let emotionContainerSpacing: CGFloat = 8
        static let emotionInfoSpacing: CGFloat = 4
        static let emotionIconSize: CGFloat = 40
        static let badgeCornerRadius: CGFloat = 12
        static let minSpacingToDate: CGFloat = 16
    }
}

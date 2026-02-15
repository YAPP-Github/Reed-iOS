// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

struct EmotionRegistrationForm {
    let primaryEmotion: PrimaryEmotion
    let detailEmotions: [DetailEmotion]
}

// MARK: - ChipFlowLayoutView

private final class ChipFlowLayoutView: UIView {
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

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for chip in chipViews {
            let chipSize = chip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

            if currentX + chipSize.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + verticalSpacing
                rowHeight = 0
            }

            chip.frame = CGRect(x: currentX, y: currentY, width: chipSize.width, height: chipSize.height)
            currentX += chipSize.width + horizontalSpacing
            rowHeight = max(rowHeight, chipSize.height)
        }

        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        let maxWidth = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width - 32 - 32

        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for chip in chipViews {
            let chipSize = chip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

            if currentX + chipSize.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + verticalSpacing
                rowHeight = 0
            }

            currentX += chipSize.width + horizontalSpacing
            rowHeight = max(rowHeight, chipSize.height)
        }

        let totalHeight = chipViews.isEmpty ? 0 : currentY + rowHeight
        return CGSize(width: UIView.noIntrinsicMetric, height: totalHeight)
    }
}

// MARK: - EmotionRowView

private final class EmotionRowView: UIView {
    private let primaryEmotion: PrimaryEmotion
    private let containerView = UIView()

    private let mainContentView = UIView()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        return imageView
    }()

    private let textStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private let titleLabel = BKLabel(
        fontStyle: .headline2(weight: .semiBold)
    )

    private let descriptionLabel = BKLabel(
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.tertiary)
    )

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: BKImage.Icon.chevronRight)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .bkContentColor(.tertiary)
        return imageView
    }()

    private let checkboxImageView: UIImageView = {
        let imageView = UIImageView(image: BKImage.Checkbox.icononlyActiveRectangle)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private let chipContainerView = UIView()
    private var chipContainerHeightConstraint: Constraint?

    private let chipFlowLayoutView = ChipFlowLayoutView()

    var isSelectedEmotion: Bool = false {
        didSet {
            updateSelectionState()
        }
    }

    var selectedDetailEmotions: [DetailEmotion] = [] {
        didSet {
            updateChips()
        }
    }

    var onDetailEmotionRemoved: ((DetailEmotion) -> Void)?

    init(primaryEmotion: PrimaryEmotion) {
        self.primaryEmotion = primaryEmotion
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(mainContentView)

        if primaryEmotion != .other {
            mainContentView.addSubview(iconImageView)
            mainContentView.addSubview(chevronImageView)
            mainContentView.addSubview(checkboxImageView)
            containerView.addSubview(chipContainerView)
            chipContainerView.addSubview(chipFlowLayoutView)
        }

        mainContentView.addSubview(textStack)
        [titleLabel, descriptionLabel].forEach(textStack.addArrangedSubview(_:))

        containerView.backgroundColor = .bkBaseColor(.secondary)
        containerView.layer.cornerRadius = 12
    }

    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        if primaryEmotion != .other {
            mainContentView.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.height.equalTo(84)
            }

            iconImageView.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(60)
            }

            textStack.snp.makeConstraints {
                $0.leading.equalTo(iconImageView.snp.trailing).offset(16)
                $0.centerY.equalToSuperview()
                $0.width.equalTo(118)
            }

            chevronImageView.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(24)
            }

            checkboxImageView.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(24)
            }

            chipContainerView.snp.makeConstraints {
                $0.top.equalTo(mainContentView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
                chipContainerHeightConstraint = $0.height.equalTo(0).constraint
            }

            chipFlowLayoutView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.leading.trailing.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview().inset(12)
            }

            chipContainerView.clipsToBounds = true
        } else {
            mainContentView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }

            textStack.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(16)
                $0.verticalEdges.equalToSuperview().inset(12)
                $0.trailing.equalToSuperview().inset(20)
            }
        }
    }

    private func configure() {
        iconImageView.image = primaryEmotion.noteImage
        titleLabel.setText(text: primaryEmotion.displayName)
        descriptionLabel.setText(text: primaryEmotion.description)
    }

    private func updateSelectionState() {
        if isSelectedEmotion {
            containerView.layer.borderWidth = 1.5
            containerView.layer.borderColor = UIColor.bkBorderColor(.brand).cgColor
            if primaryEmotion != .other {
                chevronImageView.isHidden = true
                checkboxImageView.isHidden = false
            }
        } else {
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = nil
            if primaryEmotion != .other {
                chevronImageView.isHidden = false
                checkboxImageView.isHidden = true
                chipFlowLayoutView.setChips([])
                chipContainerHeightConstraint?.activate()
            }
            selectedDetailEmotions = []
        }
    }

    private func updateChips() {
        guard primaryEmotion != .other else { return }

        guard !selectedDetailEmotions.isEmpty else {
            chipFlowLayoutView.setChips([])
            chipContainerHeightConstraint?.activate()
            return
        }

        chipContainerHeightConstraint?.deactivate()

        var chips: [UIView] = []
        for detailEmotion in selectedDetailEmotions {
            let chip = BKRemovableChip(title: detailEmotion.name) { [weak self] in
                self?.onDetailEmotionRemoved?(detailEmotion)
            }
            chips.append(chip)
        }
        chipFlowLayoutView.setChips(chips)
    }
}

// MARK: - EmotionRegistrationView

final class EmotionRegistrationView: BaseView {
    private let inputChangedSubject = PassthroughSubject<Void, Never>()

    private let containerView = UIView()

    private let titleLabel = BKLabel(
        text: "문장에 대해 어떤 감정이 드셨나요?",
        fontStyle: .heading1(weight: .bold)
    )

    private let subtitleLabel = BKLabel(
        text: "대표 감정을 한 가지 선택해주세요",
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.tertiary)
    )

    private var selectedPrimaryEmotion: PrimaryEmotion?
    private var selectedDetailEmotions: [DetailEmotion] = []
    private var isLoadingEmotions: Bool = false

    private let titleStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private let emotionListStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private var emotionRows: [PrimaryEmotion: EmotionRowView] = [:]

    // 외부에서 BottomSheet 표시를 위한 콜백
    var onEmotionSelected: ((PrimaryEmotion) -> Void)?

    override func setupView() {
        addSubview(containerView)
        containerView.addSubviews(titleStack, emotionListStack)
        [titleLabel, subtitleLabel].forEach(titleStack.addArrangedSubview(_:))
        setupEmotionRows()
    }

    override func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }

        emotionListStack.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom)
                .offset(LayoutConstants.listTopOffset)
            $0.horizontalEdges.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalToSuperview()
        }
    }

    private func setupEmotionRows() {
        let emotions: [PrimaryEmotion] = [.warmth, .joy, .sadness, .insight, .other]

        for emotion in emotions {
            let rowView = EmotionRowView(primaryEmotion: emotion)
            rowView.isUserInteractionEnabled = true

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(emotionRowTapped(_:)))
            rowView.addGestureRecognizer(tapGesture)
            rowView.tag = emotion.hashValue

            rowView.onDetailEmotionRemoved = { [weak self] detailEmotion in
                self?.removeDetailEmotion(detailEmotion)
            }

            emotionRows[emotion] = rowView
            emotionListStack.addArrangedSubview(rowView)
        }
    }

    private func removeDetailEmotion(_ detailEmotion: DetailEmotion) {
        selectedDetailEmotions.removeAll { $0 == detailEmotion }
        if let selectedPrimaryEmotion, let rowView = emotionRows[selectedPrimaryEmotion] {
            rowView.selectedDetailEmotions = selectedDetailEmotions
        }
        inputChangedSubject.send(())
    }

    @objc private func emotionRowTapped(_ sender: UITapGestureRecognizer) {
        // 로딩 중에는 탭 무시
        guard !isLoadingEmotions else { return }

        guard let tappedView = sender.view,
              let emotion = PrimaryEmotion.allCases.first(where: { $0.hashValue == tappedView.tag }) else {
            return
        }

        // 다른 감정을 선택한 경우에만 세부감정 초기화
        if selectedPrimaryEmotion != emotion {
            selectedPrimaryEmotion = emotion
            selectedDetailEmotions = []
            updateSelectionUI()
        }

        // other가 아닌 경우 바텀시트 표시 (같은 감정 재선택 시에도)
        if emotion != .other {
            onEmotionSelected?(emotion)
        } else {
            inputChangedSubject.send(())
        }
    }

    private func updateSelectionUI() {
        emotionRows.forEach { emotion, rowView in
            rowView.isSelectedEmotion = (emotion == selectedPrimaryEmotion)
            if emotion != selectedPrimaryEmotion {
                rowView.selectedDetailEmotions = []
            }
        }
    }

    /// 세부감정 선택 완료 시 호출
    func setDetailEmotions(_ detailEmotions: [DetailEmotion]) {
        selectedDetailEmotions = detailEmotions
        if let selectedPrimaryEmotion, let rowView = emotionRows[selectedPrimaryEmotion] {
            rowView.selectedDetailEmotions = detailEmotions
        }
        inputChangedSubject.send(())
    }

    /// 현재 선택된 감정 반환
    func getSelectedPrimaryEmotion() -> PrimaryEmotion? {
        return selectedPrimaryEmotion
    }

    /// 현재 선택된 세부감정 반환
    func getSelectedDetailEmotions() -> [DetailEmotion] {
        return selectedDetailEmotions
    }

    /// 로딩 상태 설정
    func setLoadingEmotions(_ isLoading: Bool) {
        isLoadingEmotions = isLoading
    }
}

// MARK: - RegistrationFormProvidable & FormInputNotifiable

extension EmotionRegistrationView: RegistrationFormProvidable, FormInputNotifiable {
    var inputChangedPublisher: AnyPublisher<Void, Never> {
        inputChangedSubject.eraseToAnyPublisher()
    }

    func registrationForm() -> RegistrationForm? {
        guard let selectedPrimaryEmotion else { return nil }

        // 대분류 감정만 선택해도 유효 (세부감정은 선택사항)
        return .emotion(.init(primaryEmotion: selectedPrimaryEmotion, detailEmotions: selectedDetailEmotions))
    }

    func setSelectedPrimaryEmotion(_ emotion: PrimaryEmotion) {
        selectedPrimaryEmotion = emotion
        updateSelectionUI()
    }
}

// MARK: - Layout Constants

private extension EmotionRegistrationView {
    enum LayoutConstants {
        static let horizontalInset = BKInset.inset5
        static let listTopOffset: CGFloat = 32
    }
}

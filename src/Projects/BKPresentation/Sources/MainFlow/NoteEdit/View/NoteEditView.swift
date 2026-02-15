// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

enum NoteEditViewEvent {
    case emotionStatusTapped
    case saveButtonTapped
    case pageDidChange(String)
    case sentenceDidChange(String)
    case memoDidChange(String)
}

final class NoteEditView: BaseView {
    let eventPublisher = PassthroughSubject<NoteEditViewEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var keyboardCancellables = Set<AnyCancellable>()
    
    private var currentFocusedInput: FocusedInput = .none
    
    private enum FocusedInput {
        case none
        case pageField
        case sentenceTextView
        case memoTextView
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let resultView = BKBookSummaryView(style: .compact)
    private let divider = BKDivider(type: .small)
    
    private let pageField = BKTextFieldView(
        labelText: "책 페이지",
        placeholder: "기록하고 싶은 페이지를 작성해보세요",
        fontStyle: .body2(weight: .medium)
    )
    
    private let sentenceTextView = BKTextView(
        labelText: "문장 기록",
        placeholder: "기록하고 싶은 문장을 작성해보세요",
        fontStyle: .body2(weight: .medium)
    )
    
    private let appreciationTextView = BKTextView(
        labelText: "감상평",
        placeholder: "문장에 대한 감상을 남겨주세요",
        fontStyle: .body2(weight: .medium)
    )
    
    // MARK: - Emotion Card Components

    private let emotionTitleLabel = BKLabel(
        text: "감정",
        fontStyle: .body1(weight: .medium)
    )

    private let emotionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .bkBaseColor(.secondary)
        view.layer.cornerRadius = BKRadius.medium
        return view
    }()

    private let emotionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20  // 40 / 2
        return imageView
    }()

    private let emotionInfoStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()

    private let emotionBadgeView: UIStackView = {
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

    private let detailEmotionsLabel = BKLabel(
        fontStyle: .caption1(weight: .regular),
        color: .bkContentColor(.tertiary)
    )

    private let emotionChevronImageView: UIImageView = {
        let imageView = UIImageView(
            image: BKImage.Icon.chevronRight
                .withRenderingMode(.alwaysTemplate)
        )
        imageView.tintColor = .bkContentColor(.tertiary)
        return imageView
    }()
    
    private let saveButton = BKButton(style: .primary, size: .large)
    
    override func setupView() {
        addSubviews(scrollView, saveButton)
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            resultView,
            divider,
            pageField,
            sentenceTextView,
            appreciationTextView,
            emotionTitleLabel,
            emotionCardView
        )

        // 감정 카드 내부 구성
        emotionBadgeView.addArrangedSubview(emotionBadgeLabel)
        [emotionBadgeView, detailEmotionsLabel].forEach(emotionInfoStack.addArrangedSubview)
        emotionCardView.addSubviews(
            emotionImageView,
            emotionInfoStack,
            emotionChevronImageView
        )
    }
    
    override func configure() {
        pageField.setTextFieldKeyboardType(.numberPad)
        pageField.setTextFieldDelegate(self)

        // 감정 카드 탭 제스처 추가
        let emotionTapGesture = UITapGestureRecognizer(target: self, action: #selector(emotionStatusTapped))
        emotionCardView.addGestureRecognizer(emotionTapGesture)
        emotionCardView.isUserInteractionEnabled = true

        // 감정 뱃지 초기 설정
        emotionBadgeView.clipsToBounds = true
        
        // BKTextFieldView와 BKTextView는 자체적으로 탭을 처리하므로 별도 제스처 불필요
        pageField.textDidChangePublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.eventPublisher.send(.pageDidChange(self.pageField.text))
            }
            .store(in: &cancellables)
        
        sentenceTextView.textDidChangePublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.eventPublisher.send(.sentenceDidChange(self.sentenceTextView.text))
            }
            .store(in: &cancellables)
        
        appreciationTextView.textDidChangePublisher
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.eventPublisher.send(.memoDidChange(self.appreciationTextView.text))
            }
            .store(in: &cancellables)
        
        // 전체 뷰에 탭 제스처 추가 (키보드 dismiss용)
        let dismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(dismissTapGesture)
        
        // 포커스 옵저버 설정
        setupTextFieldFocusHandling()
        
        // 키보드 핸들링 설정
        setupKeyboardHandling()
        
        // 저장 버튼 액션 추가
        saveButton.title = "저장하기"
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc private func emotionStatusTapped() {
        eventPublisher.send(.emotionStatusTapped)
    }
    
    @objc private func saveButtonTapped() {
        eventPublisher.send(.saveButtonTapped)
    }
    
    @objc private func dismissKeyboard() {
        currentFocusedInput = .none
        endEditing(true)
    }
    
    private func setupTextFieldFocusHandling() {
        // BKTextView의 메서드를 통한 포커스 감지
        sentenceTextView.addTextViewFocusObserver(
            target: self,
            selector: #selector(sentenceTextViewDidBeginEditing)
        )
        
        appreciationTextView.addTextViewFocusObserver(
            target: self,
            selector: #selector(appreciationTextViewDidBeginEditing)
        )
        
        // BKTextFieldView의 메서드를 통한 포커스 감지  
        pageField.addTextFieldFocusObserver(
            target: self,
            selector: #selector(pageFieldDidBeginEditing)
        )
        
    }
    
    @objc private func sentenceTextViewDidBeginEditing(_ notification: Notification) {
        currentFocusedInput = .sentenceTextView
    }
    
    @objc private func appreciationTextViewDidBeginEditing(_ notification: Notification) {
        currentFocusedInput = .memoTextView
    }
    
    @objc private func pageFieldDidBeginEditing(_ notification: Notification) {
        currentFocusedInput = .pageField
    }
    
    private func setupKeyboardHandling() {
        let keyboardWillShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return nil }
                return keyboardFrame.height
            }
        
        let keyboardWillHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat.zero }
        
        Publishers.Merge(keyboardWillShow, keyboardWillHide)
            .sink { [weak self] height in
                self?.adjustForKeyboard(height: height)
            }
            .store(in: &keyboardCancellables)
    }
    
    private func adjustForKeyboard(height: CGFloat) {
        scrollView.contentInset.bottom = height
        scrollView.verticalScrollIndicatorInsets.bottom = height
        
        // 키보드가 나타날 때만 스크롤
        if height > 0 {
            // 포커스된 입력에 따라 적절한 스크롤 수행
            switch currentFocusedInput {
            case .pageField:
                scrollToPageField()
            case .sentenceTextView:
                scrollToSentenceTextView()
            case .memoTextView:
                scrollToAppreciationTextView()
            case .none:
                break
            }
        }
    }
    
    private func scrollToPageField() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let pageFieldFrame = self.pageField.frame
            let pageFieldGlobalFrame = self.contentView.convert(pageFieldFrame, to: self.scrollView)
            
            let targetY = max(0, pageFieldGlobalFrame.minY - 20)
            self.scrollView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
        }
    }
    
    private func scrollToSentenceTextView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let sentenceTextViewFrame = self.sentenceTextView.frame
            let sentenceTextViewGlobalFrame = self.contentView.convert(sentenceTextViewFrame, to: self.scrollView)
            
            let targetY = max(0, sentenceTextViewGlobalFrame.minY - 20)
            self.scrollView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
        }
    }
    
    private func scrollToAppreciationTextView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let appreciationTextViewFrame = self.appreciationTextView.frame
            let appreciationTextViewGlobalFrame = self.contentView.convert(appreciationTextViewFrame, to: self.scrollView)
            
            let targetY = max(0, appreciationTextViewGlobalFrame.minY - 20)
            self.scrollView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
        }
    }
    
    func apply(
        recordInfo: RecordInfo
    ) {
        resultView.configure(
            title: recordInfo.bookTitle,
            author: recordInfo.author,
            publisher: recordInfo.bookPublisher,
            image: recordInfo.bookCoverImageUrl
        )
        
        pageField.setText(recordInfo.pageNumber.map { "\($0)" } ?? "")
        sentenceTextView.setText(recordInfo.quote)
        
        if let review = recordInfo.review {
            appreciationTextView.setText(review)
        }
        // 감정 라벨은 selectedEmotion 바인딩에서만 설정
    }
    
    func setEmotionInfo(primaryEmotion: PrimaryEmotion?, detailEmotions: [DetailEmotion]) {
        guard let emotion = primaryEmotion else {
            // 감정 미선택 상태
            emotionImageView.image = BKImage.Graphics.Note.default
            emotionBadgeLabel.setText(text: "감정을 선택해주세요")
            emotionBadgeView.backgroundColor = .bkBaseColor(.secondary)
            emotionBadgeLabel.setColor(color: .bkContentColor(.tertiary))
            detailEmotionsLabel.isHidden = true
            return
        }

        // 감정 이미지 설정 (40x40 원형)
        emotionImageView.image = emotion.noteImage

        // Badge 설정
        emotionBadgeLabel.setText(text: emotion.displayName)

        // 기타 감정일 때 별도 색상 처리 (카드 배경과 구분되도록)
        if emotion == .other {
            emotionBadgeView.backgroundColor = BKAtomicColor.Neutral.n200.color
            emotionBadgeLabel.setColor(color: BKAtomicColor.Neutral.n400.color)
        } else {
            emotionBadgeView.backgroundColor = emotion.baseColor
            emotionBadgeLabel.setColor(color: emotion.color)
        }

        // 세부감정 태그 설정
        if detailEmotions.isEmpty {
            detailEmotionsLabel.isHidden = true
        } else {
            let tags = detailEmotions.map { "#\($0.name)" }.joined(separator: " ")
            detailEmotionsLabel.setText(text: tags)
            detailEmotionsLabel.isHidden = false
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // pill 형태 (양 끝이 완전한 원형)
        emotionBadgeView.layoutIfNeeded()
        emotionBadgeView.layer.cornerRadius = emotionBadgeView.bounds.height / 2
    }
    
    public func setSaveButtonEnabled(_ isEnabled: Bool) {
        saveButton.isDisabled = !isEnabled
    }
    
    func getCurrentFormData() -> (page: Int?, sentence: String, memo: String) {
        let pageText = pageField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sentenceText = sentenceTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let memoText = appreciationTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        let page = pageText.isEmpty ? nil : Int(pageText)

        return (page: page, sentence: sentenceText, memo: memoText)
    }
    
    override func setupLayout() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(saveButton.snp.top).offset(-LayoutConstants.fieldSpacing)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        resultView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(LayoutConstants.resultViewHeight)
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(resultView.snp.bottom)
                .offset(LayoutConstants.dividerTopOffset)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
        }
        
        pageField.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom)
                .offset(LayoutConstants.contentTopOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.height.equalTo(LayoutConstants.textFieldHeight)
        }
        
        sentenceTextView.snp.makeConstraints {
            $0.top.equalTo(pageField.snp.bottom)
                .offset(LayoutConstants.fieldSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.height.equalTo(LayoutConstants.textViewHeight)
        }
        
        appreciationTextView.snp.makeConstraints {
            $0.top.equalTo(sentenceTextView.snp.bottom)
                .offset(LayoutConstants.fieldSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.height.equalTo(LayoutConstants.textViewHeight)
        }
        
        emotionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(appreciationTextView.snp.bottom)
                .offset(LayoutConstants.fieldSpacing)
            $0.leading.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }

        emotionCardView.snp.makeConstraints {
            $0.top.equalTo(emotionTitleLabel.snp.bottom)
                .offset(BKInset.inset1)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.height.greaterThanOrEqualTo(LayoutConstants.emotionCardMinHeight)
            $0.bottom.equalToSuperview().inset(LayoutConstants.fieldSpacing)
        }

        emotionImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(LayoutConstants.emotionCardPadding)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(LayoutConstants.emotionImageSize)
        }

        emotionInfoStack.snp.makeConstraints {
            $0.leading.equalTo(emotionImageView.snp.trailing).offset(BKSpacing.spacing2)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(emotionChevronImageView.snp.leading).offset(-BKSpacing.spacing2)
        }

        emotionChevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(LayoutConstants.emotionCardPadding)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalTo(safeAreaLayoutGuide)
                .inset(LayoutConstants.bottomInset)
            $0.height.equalTo(52)
        }
    }
}

extension NoteEditView: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.isEmpty { return true }
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        return true
    }
}

private extension NoteEditView {
    enum LayoutConstants {
        static let contentStackSpacing = BKSpacing.spacing6
        static let horizontalInset = BKInset.inset5
        static let dividerTopOffset = BKInset.inset2
        static let contentTopOffset = BKSpacing.spacing10
        static let fieldSpacing = BKSpacing.spacing8
        static let bottomInset = BKInset.inset5
        static let resultViewHeight: CGFloat = 100
        static let textFieldHeight: CGFloat = 82
        static let textViewHeight: CGFloat = 172
        static let saveButtonTopInset: CGFloat = 80
        static let saveButtonBottomInset = BKInset.inset4

        // Emotion Card
        static let emotionCardMinHeight: CGFloat = 72  // 16(padding) + 40(image) + 16(padding)
        static let emotionCardPadding = BKInset.inset4  // 16
        static let emotionImageSize: CGFloat = 40
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

enum NoteEditViewEvent {
    case emotionStatusTapped
    case saveButtonTapped
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
        case appreciationTextView
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let resultView = BKBookSummaryView(style: .compact)
    private let divider = BKDivider(type: .small)
    
    private let pageField = BKTextFieldView(
        labelText: "책 페이지",
        placeholder: "기록하고 싶은 페이지를 작성해보세요"
    )
    
    private let sentenceTextView = BKTextView(
        labelText: "문장 기록",
        placeholder: "기록하고 싶은 문장을 작성해보세요"
    )
    
    private let appreciationTextView = BKTextView(
        labelText: "감상평",
        placeholder: "문장에 대한 감상을 남겨주세요"
    )
    
    private let emotionStatusView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private let emotionTitleLabel = BKLabel(
        text: "감정",
        fontStyle: .body1(weight: .medium)
    )
    
    private let emotionRightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = BKSpacing.spacing1
        return stackView
    }()
    
    private let emotionLabel = BKLabel(
        fontStyle: .body1(weight: .medium),
        color: .bkContentColor(.secondary)
    )
    
    private let rightArrowImageView: UIImageView = {
        let imageView = UIImageView(
            image: BKImage.Icon.chevronRight
                .withRenderingMode(.alwaysTemplate)
        )
        imageView.tintColor = .bkContentColor(.secondary)
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
            emotionStatusView
        )
        
        [emotionLabel, rightArrowImageView].forEach(emotionRightStackView.addArrangedSubview)
        [emotionTitleLabel, emotionRightStackView].forEach(emotionStatusView.addArrangedSubview)
    }
    
    override func configure() {
        pageField.setTextFieldKeyboardType(.numberPad)
        pageField.setTextFieldDelegate(self)
        
        // 감정 상태 영역 탭 제스처 추가
        let emotionTapGesture = UITapGestureRecognizer(target: self, action: #selector(emotionStatusTapped))
        emotionStatusView.addGestureRecognizer(emotionTapGesture)
        emotionStatusView.isUserInteractionEnabled = true
        
        // BKTextFieldView와 BKTextView는 자체적으로 탭을 처리하므로 별도 제스처 불필요
        
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
        currentFocusedInput = .appreciationTextView
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
            case .appreciationTextView:
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
        
        pageField.setText("\(recordInfo.pageNumber)")
        sentenceTextView.setText(recordInfo.quote)
        
        if let review = recordInfo.review {
            appreciationTextView.setText(review)
        } else {
            
        }
        
        // 감정 라벨은 selectedEmotion 바인딩에서만 설정
    }
    
    func setInitialEmotion(_ emotion: Emotion?) {
        if let emotion = emotion {
            emotionLabel.setText(text: emotion.rawValue)
        } else {
            emotionLabel.setText(text: "감정을 선택해주세요")
        }
    }
    
    func updateEmotionLabel(_ text: String) {
        emotionLabel.setText(text: text)
    }
    
    func getCurrentFormData() -> (page: Int?, sentence: String, appreciation: String) {
        let pageText = pageField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sentenceText = sentenceTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let appreciationText = appreciationTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let page = pageText.isEmpty ? nil : Int(pageText)
        
        return (page: page, sentence: sentenceText, appreciation: appreciationText)
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
        
        emotionStatusView.snp.makeConstraints {
            $0.top.equalTo(appreciationTextView.snp.bottom)
                .offset(LayoutConstants.fieldSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.height.equalTo(LayoutConstants.emotionStatusViewHeight)
            $0.bottom.equalToSuperview().inset(LayoutConstants.fieldSpacing)
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
        static let emotionStatusViewHeight: CGFloat = 24
        static let saveButtonTopInset: CGFloat = 80
        static let saveButtonBottomInset = BKInset.inset4
    }
}

// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit

struct SentenceRegistrationForm {
    let page: Int
    let sentence: String
}

final class SentenceRegistrationView: BaseView {
    private let inputChangedSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private let containerView = UIView()
    private let titleLabel = BKLabel(
        text: """
        기록하고 싶은 페이지와 
        문장을 등록해보세요
        """,
        fontStyle: .heading1(weight: .bold)
    )
    
    private let pageField = BKTextFieldView(
        labelText: "책 페이지",
        placeholder: "기록하고 싶은 페이지를 작성해보세요"
    )
    
    private let sentenceTextView = BKTextView(
        labelText: "문장 기록",
        placeholder: "기록하고 싶은 문장을 작성해보세요"
    )
    
    private let textScanButton = BKButton(
        style: .stroke,
        size: .rounded
    )
    
    private let tooltipView = TooltipView(text: "스캔으로 빠르게 입력해요")
    
    var onTextScanTapped: (() -> Void)?
    var onPageFieldFocused: (() -> Void)?
    var onSentenceTextViewFocused: (() -> Void)?
    
    var scanButtonFrame: CGRect {
        return textScanButton.frame
    }
    
    var pageFieldFrame: CGRect {
        return pageField.frame
    }
    
    var sentenceTextViewFrame: CGRect {
        return sentenceTextView.frame
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        bindInputs()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setupView() {
        addSubviews(
            titleLabel,
            pageField,
            sentenceTextView,
            textScanButton,
            tooltipView
        )
    }
    
    override func configure() {
        titleLabel.numberOfLines = .zero
        textScanButton.title = "문장 스캔하기"
        textScanButton.leftIcon = BKImage.Icon.maximize
        pageField.setTextFieldDelegate(self)
        pageField.setTextFieldKeyboardType(.numberPad)
        textScanButton.addTarget(self, action: #selector(textScanButtonTapped), for: .touchUpInside)
        
        setupTextFieldFocusHandling()
    }
    
    override func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        pageField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(LayoutConstants.pageFieldOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        sentenceTextView.snp.makeConstraints {
            $0.top.equalTo(pageField.snp.bottom)
                .offset(LayoutConstants.sentenceViewOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
        
        textScanButton.snp.makeConstraints {
            $0.top.equalTo(sentenceTextView.snp.bottom)
                .offset(LayoutConstants.buttonOffset)
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalToSuperview()
        }
        
        tooltipView.snp.makeConstraints {
            $0.centerY.equalTo(textScanButton)
            $0.trailing.equalTo(textScanButton.snp.leading).offset(-8)
            $0.height.equalTo(34)
        }
    }
}

extension SentenceRegistrationView: RegistrationFormProvidable, FormInputNotifiable {
    var inputChangedPublisher: AnyPublisher<Void, Never> {
        inputChangedSubject.eraseToAnyPublisher()
    }
    
    func registrationForm() -> RegistrationForm? {
        let trimmedPage = pageField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSentence = sentenceTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedPage.isEmpty,
              !trimmedSentence.isEmpty,
              let page = Int(trimmedPage)
        else {
            return nil
        }

        return .sentence(SentenceRegistrationForm(
            page: page,
            sentence: trimmedSentence
        ))
    }
    
    private func bindInputs() {
        pageField.textDidChangePublisher
            .merge(with: sentenceTextView.textDidChangePublisher)
            .sink { [weak self] _ in
                self?.inputChangedSubject.send(())
            }
            .store(in: &cancellables)
    }
    
    @objc func textScanButtonTapped() {
        tooltipView.isHidden = true
        onTextScanTapped?()
    }
    
    func setScannedText(_ text: String) {
        sentenceTextView.setText(text)
        inputChangedSubject.send(())
    }
    
    private func setupTextFieldFocusHandling() {
        // BKTextView의 메서드를 통한 포커스 감지
        sentenceTextView.addTextViewFocusObserver(
            target: self,
            selector: #selector(textViewDidBeginEditing)
        )
        
        // BKTextFieldView의 메서드를 통한 포커스 감지  
        pageField.addTextFieldFocusObserver(
            target: self,
            selector: #selector(pageFieldDidBeginEditing)
        )
    }
    
    @objc private func textViewDidBeginEditing(_ notification: Notification) {
        onSentenceTextViewFocused?()
    }
    
    @objc private func pageFieldDidBeginEditing(_ notification: Notification) {
        onPageFieldFocused?()
    }
}

extension SentenceRegistrationView: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.isEmpty { return true }
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }

        let current = textField.text ?? ""
        guard let range = Range(range, in: current) else { return false }
        let newText = current.replacingCharacters(in: range, with: string)

        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }
        if trimmed.hasPrefix("0") { return false }
        if trimmed.count > 4 { return false }

        if let value = Int(trimmed), value <= 9999 { return true }
        return false
    }
}

private extension SentenceRegistrationView {
    enum LayoutConstants {
        static let horizontalInset = BKInset.inset5
        static let buttonBorderWidth = BKBorder.border1
        static let pageFieldOffset: CGFloat = 40
        static let sentenceViewOffset: CGFloat = 32
        static let buttonOffset: CGFloat = 12
        static let buttonHeight: CGFloat = 38
    }
}

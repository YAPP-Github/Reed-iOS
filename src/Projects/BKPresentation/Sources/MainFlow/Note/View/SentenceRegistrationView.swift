// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit

struct SentenceRegistrationForm {
    let page: Int?
    let sentence: String
    let memo: String?
}

final class SentenceRegistrationView: BaseView {
    private let inputChangedSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Title Section

    private let titleLabel = BKLabel(
        text: """
        기록하고 싶은 페이지와 
        문장을 등록해보세요
        """,
        fontStyle: .heading1(weight: .bold)
    )

    // MARK: - Sentence Section (Required)

    private let sentenceLabelRow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = LayoutConstants.labelBadgeSpacing
        stackView.alignment = .center
        return stackView
    }()

    private let sentenceLabel = BKLabel(
        text: "문장 기록",
        fontStyle: .body1(weight: .medium)
    )

    private let sentenceTextView = BKTextView(
        placeholder: "기록하고 싶은 문장을 작성해보세요"
    )

    private let textScanButton = BKButton(
        style: .tertiary,
        size: .medium
    )

    // MARK: - Page Section (Optional)

    private let pageLabelRow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = LayoutConstants.labelBadgeSpacing
        stackView.alignment = .center
        return stackView
    }()

    private let pageLabel = BKLabel(
        text: "책 페이지",
        fontStyle: .body1(weight: .medium)
    )

    private let pageBadge = BadgeView(title: "선택")

    private let pageField = BKTextFieldView(
        placeholder: "기록하고 싶은 페이지를 작성해보세요"
    )

    // MARK: - Memo Section (Optional)

    private let memoLabelRow: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = LayoutConstants.labelBadgeSpacing
        stackView.alignment = .center
        return stackView
    }()

    private let memoLabel = BKLabel(
        text: "메모",
        fontStyle: .body1(weight: .medium)
    )

    private let memoBadge = BadgeView(title: "선택")

    private let memoTextView = BKTextView(
        placeholder: "기록하고 싶은 메모가 있다면 작성해보세요"
    )

    // MARK: - Callbacks

    var onTextScanTapped: (() -> Void)?
    var onPageFieldFocused: (() -> Void)?
    var onSentenceTextViewFocused: (() -> Void)?
    var onMemoTextViewFocused: (() -> Void)?

    // MARK: - Frame Accessors

    var scanButtonFrame: CGRect {
        return textScanButton.frame
    }

    var pageFieldFrame: CGRect {
        return pageField.frame
    }

    var sentenceTextViewFrame: CGRect {
        return sentenceTextView.frame
    }

    var memoTextViewFrame: CGRect {
        return memoTextView.frame
    }

    // MARK: - Lifecycle

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        bindInputs()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func setupView() {
        // Sentence label row
        [sentenceLabel].forEach(sentenceLabelRow.addArrangedSubview(_:))

        // Page label row with badge
        [pageLabel, pageBadge].forEach(pageLabelRow.addArrangedSubview(_:))
        pageLabelRow.addArrangedSubview(UIView()) // spacer

        // Memo label row with badge
        [memoLabel, memoBadge].forEach(memoLabelRow.addArrangedSubview(_:))
        memoLabelRow.addArrangedSubview(UIView()) // spacer

        addSubviews(
            titleLabel,
            sentenceLabelRow,
            sentenceTextView,
            textScanButton,
            pageLabelRow,
            pageField,
            memoLabelRow,
            memoTextView
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

        // Sentence section
        sentenceLabelRow.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
                .offset(LayoutConstants.sectionTopOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }

        sentenceTextView.snp.makeConstraints {
            $0.top.equalTo(sentenceLabelRow.snp.bottom)
                .offset(LayoutConstants.labelToFieldSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }

        textScanButton.snp.makeConstraints {
            $0.top.equalTo(sentenceTextView.snp.bottom)
                .offset(LayoutConstants.buttonOffset)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }

        // Page section
        pageLabelRow.snp.makeConstraints {
            $0.top.equalTo(textScanButton.snp.bottom)
                .offset(LayoutConstants.sectionSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }

        pageField.snp.makeConstraints {
            $0.top.equalTo(pageLabelRow.snp.bottom)
                .offset(LayoutConstants.labelToFieldSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }

        // Memo section
        memoLabelRow.snp.makeConstraints {
            $0.top.equalTo(pageField.snp.bottom)
                .offset(LayoutConstants.sectionSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }

        memoTextView.snp.makeConstraints {
            $0.top.equalTo(memoLabelRow.snp.bottom)
                .offset(LayoutConstants.labelToFieldSpacing)
            $0.leading.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - RegistrationFormProvidable & FormInputNotifiable

extension SentenceRegistrationView: RegistrationFormProvidable, FormInputNotifiable {
    var inputChangedPublisher: AnyPublisher<Void, Never> {
        inputChangedSubject.eraseToAnyPublisher()
    }

    func registrationForm() -> RegistrationForm? {
        let trimmedSentence = sentenceTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSentence.isEmpty else {
            return nil
        }

        let trimmedPage = pageField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let page: Int? = trimmedPage.isEmpty ? nil : Int(trimmedPage)

        let trimmedMemo = memoTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let memo: String? = trimmedMemo.isEmpty ? nil : trimmedMemo

        return .sentence(SentenceRegistrationForm(
            page: page,
            sentence: trimmedSentence,
            memo: memo
        ))
    }

    private func bindInputs() {
        pageField.textDidChangePublisher
            .merge(with: sentenceTextView.textDidChangePublisher)
            .merge(with: memoTextView.textDidChangePublisher)
            .sink { [weak self] _ in
                self?.inputChangedSubject.send(())
            }
            .store(in: &cancellables)
    }

    @objc func textScanButtonTapped() {
        onTextScanTapped?()
    }

    func setScannedText(_ text: String) {
        sentenceTextView.setText(text)
        inputChangedSubject.send(())
    }

    private func setupTextFieldFocusHandling() {
        sentenceTextView.addTextViewFocusObserver(
            target: self,
            selector: #selector(sentenceTextViewDidBeginEditing)
        )

        pageField.addTextFieldFocusObserver(
            target: self,
            selector: #selector(pageFieldDidBeginEditing)
        )

        memoTextView.addTextViewFocusObserver(
            target: self,
            selector: #selector(memoTextViewDidBeginEditing)
        )
    }

    @objc private func sentenceTextViewDidBeginEditing(_ notification: Notification) {
        onSentenceTextViewFocused?()
    }

    @objc private func pageFieldDidBeginEditing(_ notification: Notification) {
        onPageFieldFocused?()
    }

    @objc private func memoTextViewDidBeginEditing(_ notification: Notification) {
        onMemoTextViewFocused?()
    }
}

// MARK: - UITextFieldDelegate

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

// MARK: - Layout Constants

private extension SentenceRegistrationView {
    enum LayoutConstants {
        static let horizontalInset = BKInset.inset5
        static let sectionTopOffset: CGFloat = 40
        static let sectionSpacing: CGFloat = 48
        static let labelToFieldSpacing: CGFloat = 8
        static let labelBadgeSpacing: CGFloat = 8
        static let buttonOffset: CGFloat = 12
    }
}

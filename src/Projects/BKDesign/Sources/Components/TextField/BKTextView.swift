// Copyright © 2025 Booket. All rights reserved

/// 기존 `BKTextView`를 `BKTextFieldView`로 네이밍 변경하고,
/// 멀티라인 입력용 `BKTextView`를 새로 추가합니다.

import Combine
import SnapKit
import UIKit

public final class BKTextView: UIView {
    private let titleLabel = BKLabel()
    private let textView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = BKRadius.small
        textView.layer.borderWidth = LayoutConstants.borderWidth
        textView.layer.borderColor = UIColor.bkBorderColor(.primary).cgColor
        textView.backgroundColor = .bkBackgroundColor(.secondary)
        textView.isScrollEnabled = true
        textView.font = BKTextStyle.body2(weight: .regular).uiFont
        textView.textColor = .bkContentColor(.primary)
        textView.textContainerInset = UIEdgeInsets(
            top: LayoutConstants.contentTitleInset,
            left: LayoutConstants.contentTitleInset,
            bottom: LayoutConstants.contentTitleInset,
            right: LayoutConstants.contentTitleInset
        )
        textView.textContainer.lineFragmentPadding = .zero
        return textView
    }()
    
    private let placeholderLabel = BKLabel(
        fontStyle: .body2(weight: .regular),
        color: .bkContentColor(.tertiary)
    )
    
    private let errorMessageLabel = BKLabel(type: .error)

    private var labelText: String? {
        didSet {
            updateTitleLabel(with: labelText)
        }
    }
    private var placeholderText: String
    private var errorMessage: String? {
        didSet {
            updateErrorMessageLabel(with: errorMessage)
        }
    }
    
    private let textViewMinHeight: CGFloat

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = BKSpacing.spacing2
        stackView.alignment = .fill
        return stackView
    }()
    
    private let textDidChangeSubject = PassthroughSubject<Void, Never>()
    public var textDidChangePublisher: AnyPublisher<Void, Never> {
        textDidChangeSubject.eraseToAnyPublisher()
    }
    
    public var text: String {
        return textView.text ?? ""
    }

    public init(
        frame: CGRect = .zero,
        labelText: String? = nil,
        placeholder: String = "",
        minHeight: CGFloat = 140
    ) {
        self.labelText = labelText
        self.placeholderText = placeholder
        self.textViewMinHeight = minHeight
        super.init(frame: frame)
        setup()
        layoutViews()
        textView.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setLabelText(_ text: String?) {
        self.labelText = text
    }
    
    public func setErrorMessage(_ errorMessage: String) {
        self.errorMessage = errorMessage
    }
    
    public func setText(_ text: String) {
        self.textView.text = text
        textViewDidChange(textView)
    }
    
    public func startEditing() {
        textView.selectedRange = NSRange(location: 0, length: 0)
        textView.becomeFirstResponder()
    }
}

private extension BKTextView {
    func setup() {
        placeholderLabel.setText(text: placeholderText)
        placeholderLabel.isUserInteractionEnabled = false
        
        textView.addSubview(placeholderLabel)
        if let labelText = labelText, !labelText.isEmpty {
            titleLabel.setText(text: labelText)
            addSubview(titleLabel)
        }

        stackView.addArrangedSubview(textView)
        addSubviews(titleLabel, stackView)
    }
    
    func layoutViews() {
        if titleLabel.superview != nil {
            titleLabel.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
            }
            stackView.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(LayoutConstants.textViewOffset)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        } else {
            stackView.snp.makeConstraints {
                $0.top.leading.trailing.bottom.equalToSuperview()
            }
        }
        
        textView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(textViewMinHeight)
        }
        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(textView.snp.top).offset(LayoutConstants.contentTitleInset)
            $0.leading.equalTo(textView.snp.leading).offset(LayoutConstants.contentTitleInset)
        }
    }
    
    func updateTitleLabel(with text: String?) {
        if let text = text, !text.isEmpty {
            if titleLabel.superview == nil {
                addSubview(titleLabel)
                layoutViews()
            }
            titleLabel.setText(text: text)
        } else {
            titleLabel.removeFromSuperview()
            layoutViews()
        }

        UIView.animate(withDuration: 0.25) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    func updateErrorMessageLabel(with message: String?) {
        if let msg = message {
            if errorMessageLabel.superview == nil {
                stackView.addArrangedSubview(errorMessageLabel)
            }
            errorMessageLabel.setText(text: msg)
        } else {
            stackView.removeArrangedSubview(errorMessageLabel)
            errorMessageLabel.removeFromSuperview()
            errorMessageLabel.setText(text: "")
        }
        
        textView.layer.borderColor = (message != nil)
            ? UIColor.bkBorderColor(.error).cgColor
            : UIColor.bkBorderColor(.primary).cgColor

        UIView.animate(withDuration: 0.25) {
            self.superview?.layoutIfNeeded()
        }
    }
}

extension BKTextView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        if !textView.text.isEmpty { textDidChangeSubject.send(()) }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

private extension BKTextView {
    enum LayoutConstants {
        static let textViewOffset = BKInset.inset2
        static let contentTitleInset = BKInset.inset4
        static let borderWidth = BKBorder.border1
    }
}

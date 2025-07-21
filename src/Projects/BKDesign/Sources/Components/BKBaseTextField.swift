// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

public class BKBaseTextField: UITextField {
    public enum TextFieldType {
        case normal
        case brand
        case error
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: LayoutConstants.height
        )
    }
    
    override public var placeholder: String? {
        didSet {
            applyPlaceholderStyle()
        }
    }
    
    var textFieldType: TextFieldType {
        didSet {
            typeDidChanged()
        }
    }
    
    private let textFont = BKTextStyle.body2(weight: .medium).uiFont
    private let placeholderFont = BKTextStyle.body2(weight: .regular).uiFont
    let clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(BKImage.Icon.xCircle, for: .normal)
        button.tintColor = .bkContentColor(.tertiary)
        return button
    }()
    
    var onReturn: ((String) -> Void)?
    
    public init(
        frame: CGRect = .zero,
        placeholder: String = "",
        type: TextFieldType = .normal
    ) {
        self.textFieldType = type
        super.init(frame: frame)
        self.placeholder = placeholder
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(
            by: UIEdgeInsets(
                top: LayoutConstants.verticalInset,
                left: LayoutConstants.horizontalInset,
                bottom: LayoutConstants.verticalInset,
                right: LayoutConstants.textRightInset
            )
        )
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(
            by: UIEdgeInsets(
                top: LayoutConstants.verticalInset,
                left: LayoutConstants.horizontalInset,
                bottom: LayoutConstants.verticalInset,
                right: LayoutConstants.textRightInset
            )
        )
    }
    
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(
            by: UIEdgeInsets(
                top: LayoutConstants.verticalInset,
                left: LayoutConstants.horizontalInset,
                bottom: LayoutConstants.verticalInset,
                right: LayoutConstants.textRightInset
            )
        )
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    public func setOnReturn(_ handler: @escaping (String) -> Void) {
        self.onReturn = handler
    }
    
    public func setType(type: TextFieldType) {
        self.textFieldType = type
    }
    
    func typeDidChanged() {
        layer.borderColor = textFieldType.borderColor.cgColor
    }
}

extension BKBaseTextField: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        guard let text, !text.isEmpty else {
            setType(type: .error)
            return false
        }
        setType(type: .brand)
        onReturn?(text)
        return true
    }
}

private extension BKBaseTextField {
    func configure() {
        delegate = self
        returnKeyType = .done
        layer.cornerRadius = BKRadius.small
        layer.borderWidth = LayoutConstants.borderWidth
        layer.borderColor = textFieldType.borderColor.cgColor
        backgroundColor = .bkBackgroundColor(.secondary)
        font = BKTextStyle.body2(weight: .medium).uiFont
        textColor = .bkContentColor(.primary)
        textAlignment = .natural
        applyClearButtonStyle()
        applyPlaceholderStyle()
    }
    
    func applyClearButtonStyle() {
        let containerView = UIView()
        containerView.addSubview(clearButton)
        addTarget(self, action: #selector(updateClearButtonVisibility), for: .editingChanged)
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        rightView = containerView
        rightViewMode = .whileEditing
        
        clearButton.snp.makeConstraints {
            $0.height.width.equalTo(LayoutConstants.clearButtonSize)
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.horizontalInset)
        }
    }
    
    func applyPlaceholderStyle() {
        guard let placeholderStr = placeholder,
              let textFont,
              let placeholderFont else { return }

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.minimumLineHeight = textFont.lineHeight
        paragraph.maximumLineHeight = textFont.lineHeight

        let baseline = (textFont.capHeight - placeholderFont.capHeight) / 2

        attributedPlaceholder = BKTextStyle
            .body2(weight: .regular)
            .attributedString(
                from: placeholderStr,
                color: .bkContentColor(.tertiary),
                extraAttributes: [
                    .baselineOffset: baseline,
                    .paragraphStyle: paragraph
                ]
            )
    }
    
    @objc private func clearButtonTapped() {
        text = ""
        clearButton.isHidden = true
    }
    
    @objc private func updateClearButtonVisibility() {
        clearButton.isHidden = (text?.isEmpty ?? true)
    }
    
    enum LayoutConstants {
        static let height: CGFloat = 50
        static let clearButtonSize: CGFloat = 22
        static let horizontalInset = BKInset.inset4
        static let verticalInset = BKInset.inset3_2
        static let borderWidth = BKBorder.border1
        static let textRightInset: CGFloat = 46
    }
}

extension BKBaseTextField.TextFieldType {
    var borderColor: UIColor {
        switch self {
        case .normal:
            return .bkBorderColor(.primary)
        case .brand:
            return .bkBorderColor(.brand)
        case .error:
            return .bkBorderColor(.error)
        }
    }
    
    var searchButtonColor: UIColor {
        switch self {
        case .normal:
            return .bkContentColor(.primary)
        case .brand:
            return .bkContentColor(.brand)
        case .error:
            return .bkContentColor(.primary)
        }
    }
}

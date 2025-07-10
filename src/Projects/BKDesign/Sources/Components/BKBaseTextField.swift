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
    
    private var type: TextFieldType {
        didSet {
            layer.borderColor = type.borderColor.cgColor
        }
    }
    
    private let textFont = BKTextStyle.body2(weight: .medium).uiFont
    private let placeholderFont = BKTextStyle.body2(weight: .regular).uiFont
    
    public init(
        frame: CGRect = .zero,
        placeholder: String = "",
        type: TextFieldType = .normal
    ) {
        self.type = type
        super.init(frame: frame)
        self.placeholder = placeholder
        setup()
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
                right: LayoutConstants.horizontalInset
            )
        )
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(
            by: UIEdgeInsets(
                top: LayoutConstants.verticalInset,
                left: LayoutConstants.horizontalInset,
                bottom: LayoutConstants.verticalInset,
                right: LayoutConstants.horizontalInset
            )
        )
    }
    
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(
            by: UIEdgeInsets(
                top: LayoutConstants.verticalInset,
                left: LayoutConstants.horizontalInset,
                bottom: LayoutConstants.verticalInset,
                right: LayoutConstants.horizontalInset
            )
        )
    }
    
    public func setType(type: TextFieldType) {
        self.type = type
    }
}

/// 필요 시 추가
extension BKBaseTextField: UITextFieldDelegate {
    
}

private extension BKBaseTextField {
    func setup() {
        layer.cornerRadius = BKRadius.small
        layer.borderWidth = LayoutConstants.borderWidth
        layer.borderColor = type.borderColor.cgColor
        backgroundColor = .bkBackgroundColor(.secondary)
        font = BKTextStyle.body2(weight: .medium).uiFont
        textColor = .bkContentColor(.primary)
        textAlignment = .justified
        applyPlaceholderStyle()
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
    
    enum LayoutConstants {
        static let height: CGFloat = 50
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 13
        static let borderWidth: CGFloat = 1
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
}

// Copyright © 2025 Booket. All rights reserved

import UIKit

public final class BKLabel: UILabel {
    public enum LabelType {
        case medium
        case small
        case help
        case success
        case error
    }
    
    private var labelText: String
    private var fontStyle: BKTextStyle
    private var labelColor: UIColor
    private var alignment: NSTextAlignment
    
    @available(*, unavailable, message: "Use `setText(_:)` instead.")
    override public var text: String? {
        get { super.text }
        set { super.text = newValue }
    }
    
    @available(*, unavailable, message: "Use `setColor(_:)` instead.")
    override public var textColor: UIColor! {
        get { super.textColor }
        set { super.textColor = newValue }
    }

    @available(*, unavailable, message: "Implement `setFont(_:)` instead.")
    override public var font: UIFont! {
        get { super.font }
        set { super.font = newValue }
    }
    
    public init(
        frame: CGRect = .zero,
        text: String = "",
        fontStyle: BKTextStyle = .body1(weight: .medium),
        color: UIColor = .bkContentColor(.primary),
        alignment: NSTextAlignment = .justified
    ) {
        self.labelText = text
        self.fontStyle = fontStyle
        self.labelColor = color
        self.alignment = alignment
        super.init(frame: frame)
        apply()
    }
    
    convenience public init(
        frame: CGRect = .zero,
        text: String = "",
        type: LabelType,
        alignment: NSTextAlignment = .justified
    ) {
        self.init(
            frame: frame,
            text: text,
            fontStyle: type.fontStyle,
            color: type.color,
            alignment: alignment
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setText(text: String) {
        self.labelText = text
        apply()
    }
    
    public func setColor(color: UIColor) {
        self.labelColor = color
        apply()
    }
}

private extension BKLabel {
    func apply() {
        let baseText = fontStyle.attributedString(
            from: labelText,
            color: labelColor
        )
        let attributedString = NSMutableAttributedString(attributedString: baseText)
        let range = NSRange(location: 0, length: attributedString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: range
        )
        
        attributedText = attributedString
    }
}

extension BKLabel.LabelType {
    var fontStyle: BKTextStyle {
        switch self {
        case .medium:
            return .body1(weight: .medium)
        case .small:
            return .label1(weight: .medium)
        case .help, .error, .success:
            return .label2(weight: .regular)
        }
    }
    
    var color: UIColor {
        switch self {
        case .medium, .small:
            return .bkContentColor(.primary)
        case .help:
            return .bkContentColor(.tertiary)
        case .success:
            return .bkContentColor(.success)
        case .error:
            return .bkContentColor(.error)
        }
    }
}

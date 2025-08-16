// Copyright © 2025 Booket. All rights reserved

import Combine
import UIKit

public final class BKTextFieldView: UIView {
    private let titleLabel = BKLabel2()
    private let textField = BKBaseTextField()
    private let helpMessageLabel = BKLabel(type: .help)
    
    private var labelText: String
    private var placeholder: String
    private var helpMessage: String
    
    private var isError: Bool = false {
        didSet {
            isError ? textField.setType(type: .error) : textField.setType(type: .normal)
        }
    }
    
    private let textDidChangeSubject = PassthroughSubject<Void, Never>()
    public var textDidChangePublisher: AnyPublisher<Void, Never> {
        textDidChangeSubject.eraseToAnyPublisher()
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: LayoutConstants.height
        )
    }
    
    public var text: String {
        return textField.text ?? ""
    }
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = BKSpacing.spacing2
        stackView.alignment = .fill
        return stackView
    }()
    
    public init(
        frame: CGRect = .zero,
        labelText: String = "",
        placeholder: String = "",
        helpMessage: String = "",
        isError: Bool = false
    ) {
        self.labelText = labelText
        self.placeholder = placeholder
        self.helpMessage = helpMessage
        self.isError = isError
        super.init(frame: frame)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    public func setHelpMessage(
        _ message: String,
        isError: Bool = false
    ) {
        helpMessageLabel.setText(text: message)
        self.isError = isError
    }
    
    public func setTextFieldDelegate(_ delegate: UITextFieldDelegate?) {
        textField.delegate = delegate
    }
    
    public func setTextFieldKeyboardType(_ type: UIKeyboardType) {
        textField.keyboardType = type
    }
}

private extension BKTextFieldView {
    func handleError() {
        if isError {
            textField.setType(type: .error)
            helpMessageLabel.setColor(color: .bkContentColor(.error))
        } else {
            textField.setType(type: .normal)
            helpMessageLabel.setColor(color: .bkContentColor(.tertiary))
        }
    }
    
    func setup() {
        titleLabel.setText(text: labelText)
        textField.placeholder = placeholder
        helpMessageLabel.setText(text: helpMessage)
        handleError()
        
        [titleLabel, textField, helpMessageLabel]
            .forEach(stackView.addArrangedSubview(_:))
        addSubview(stackView)
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    func layout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    @objc private func textDidChange() {
        if !text.isEmpty { textDidChangeSubject.send(()) }
    }
    
    enum LayoutConstants {
        static let height: CGFloat = 108
    }
}

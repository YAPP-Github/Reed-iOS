// Copyright © 2025 Booket. All rights reserved

import UIKit

public final class BKCheckBoxLabel: UIView {
    private let hStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    private let container = UIView()
    private let checkbox: BKCheckBox
    private let label: BKLabel
    private let spacing: CGFloat
    private let touchAreaInset: CGFloat?
    
    public var onChecked: ((Bool) -> Void)?
    public var isChecked: Bool = false {
        didSet {
            onChecked?(isChecked)
        }
    }
    
    public init(
        checkboxType type: BKCheckBox.CheckboxType = .round,
        labelText text: String = "",
        labelFont font: BKTextStyle = .body1(weight: .medium),
        labelColor color: UIColor = .bkContentColor(.primary),
        spacing: CGFloat = BKInset.inset2,
        touchAreaInset: CGFloat? = nil
    ) {
        self.checkbox = BKCheckBox(type: type)
        self.label = BKLabel(
            text: text,
            fontStyle: font,
            color: color,
            alignment: .left
        )
        self.spacing = spacing
        self.touchAreaInset = touchAreaInset
        super.init(frame: .zero)
        
        setup()
        configure()
        layout()
        bindContainerTapIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BKCheckBoxLabel {
    func setup() {
        container.addSubview(checkbox)
        [container, label].forEach(hStack.addArrangedSubview(_:))
        addSubview(hStack)
    }
    
    func configure() {
        hStack.spacing = spacing
        checkbox.setContentHuggingPriority(.required, for: .horizontal)
        checkbox.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func layout() {
        if let touchAreaInset {
            checkbox.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(touchAreaInset)
            }
        } else {
            checkbox.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        hStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bindContainerTapIfNeeded() {
        container.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapContainer))
        container.addGestureRecognizer(tap)
    }

    @objc private func didTapContainer() {
        checkbox.isChecked.toggle()
        isChecked = checkbox.isChecked
    }
}

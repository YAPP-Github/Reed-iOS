// Copyright © 2025 Booket. All rights reserved

import SnapKit
import UIKit

/// UISearchBar를 커스텀하거나, TextField로 UISearchBar를 구현할거냐 선택해야 함
/// 아래 구현체는 후자를 위해 사용됩니다.
public final class BKSearchTextField: BKBaseTextField {
    private let searchButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = BKImage.Icon.search.withRenderingMode(.alwaysTemplate)
        config.contentInsets = .zero
        config.titlePadding = .zero
        config.imagePadding = .zero
        config.baseForegroundColor = .bkContentColor(.primary)
        config.baseBackgroundColor = .clear
        config.background.backgroundColor = .clear
        return UIButton(configuration: config, primaryAction: nil)
    }()
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets())
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets())
    }
    
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets())
    }
    
    public override init(
        frame: CGRect = .zero,
        placeholder: String = "",
        type: BKBaseTextField.TextFieldType = .normal
    ) {
        super.init(
            frame: frame,
            placeholder: placeholder,
            type: type
        )
        setup()
        configure()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func typeDidChanged() {
        layer.borderColor = textFieldType.borderColor.cgColor
        searchButton.configuration?.baseForegroundColor = textFieldType.searchButtonColor
    }
}

private extension BKSearchTextField {
    func setup() {
        addSubview(searchButton)
    }
    
    func configure() {
        returnKeyType = .search
        searchButton.configuration?.baseForegroundColor = textFieldType.searchButtonColor
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    
    func layout() {
        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
                .inset(BKInset.inset4)
            $0.centerY.equalToSuperview()
        }
        
        clearButton.snp.remakeConstraints {
            $0.height.width.equalTo(LayoutConstants.clearButtonSize)
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.equalToSuperview()
                .inset(LayoutConstants.clearButtonHorizontalInset)
        }
    }
    
    func textInsets() -> UIEdgeInsets {
        return UIEdgeInsets(
            top: LayoutConstants.verticalInset,
            left: LayoutConstants.horizontalInset,
            bottom: LayoutConstants.verticalInset,
            right: LayoutConstants.textRightInset
        )
    }
    
    @objc func searchButtonTapped() {
        guard let text, !text.isEmpty else {
            setType(type: .error)
            return
        }
        setType(type: .brand)
        onReturn?(text)
    }
    
    enum LayoutConstants {
        static let clearButtonSize: CGFloat = 24
        static let clearButtonHorizontalInset: CGFloat = 48
        static let verticalInset = BKInset.inset3_2
        static let horizontalInset = BKInset.inset4
        static let textRightInset: CGFloat = 78
    }
}

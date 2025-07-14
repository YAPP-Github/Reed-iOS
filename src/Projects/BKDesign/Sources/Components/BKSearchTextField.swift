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
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setSearchButtonTarget(
        _ target: Any?,
        action: Selector,
        for controlEvents: UIControl.Event = .touchUpInside
    ) {
        searchButton.addTarget(target, action: action, for: controlEvents)
    }
}

private extension BKSearchTextField {
    func setup() {
        addSubview(searchButton)
    }
    
    func layout() {
        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
                .inset(BKInset.inset4)
            $0.centerY.equalToSuperview()
        }
    }
    
    func textInsets() -> UIEdgeInsets {
        return UIEdgeInsets(
            top: BKInset.inset2,
            left: BKInset.inset4,
            bottom: BKInset.inset2,
            right: BKInset.inset11
        )
    }
}
